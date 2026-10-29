import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Generates the Swift declarations for an ontology's terms.
///
/// - A class becomes a protocol (`Fauna.Animal`) whose requirements are the
///   properties with the class as `Domain`, typed by their `Range`: many
///   values (`RDFCore.PropertyValues<any Fauna.Habitat>`) by default, at most
///   one (`RDFCore.PropertyValue<any Fauna.Diet>`) for an
///   `owl:FunctionalProperty`. `SubClassOf` becomes protocol refinement; a
///   class with no superclass refines ``RDFCore/Resource``.
/// - Each class also gets an individual type, a final class named after the
///   class (`Fauna.AnimalIndividual`) that conforms to the class protocol and
///   stores every requirement. Its instances are individuals of the class:
///   references, whose identity is the object, created in an
///   ``RDFCore/IndividualGraph`` that owns their lifetime.
/// - A named individual becomes a static constant of the ontology
///   (`Fauna.carnivore`), the one instance of a final class that conforms to
///   all of its classes.
/// - A datatype, `rdfs:Literal` and its subclasses become value types that
///   store the literal (``RDFCore/LiteralValue``).
/// - A property becomes a term type that names its `Domain` and `Range`.
/// - A term that RDFCore already provides becomes an alias of that type.
///
/// Each generated type's IRI is computed here from the namespace and emitted
/// as a literal in its static metadata, for the boundary only. Generated code
/// never builds an identity at runtime.
struct EntityGenerator {
    let model: OntologyModel
    let context: any MacroExpansionContext

    private var ontology: ParsedOntology { model.ontology }

    static func generate(ontology: ParsedOntology, in context: some MacroExpansionContext) -> [DeclSyntax] {
        EntityGenerator(model: OntologyModel(ontology: ontology), context: context).generate()
    }

    func generate() -> [DeclSyntax] {
        diagnoseUndeclaredTerms()
        var generated: Set<String> = []
        return ontology.declarations.flatMap { declaration -> [DeclSyntax] in
            // A term declared twice gets one type.
            guard generated.insert(declaration.name).inserted, let shape = model.shape(of: declaration.name) else { return [] }
            let sources: [String]
            switch shape {
            case .alias(let form, let isGeneric):
                sources = [alias(declaration, form: form, isGeneric: isGeneric)]
            case .classProtocol:
                sources = classProtocol(declaration)
            case .value:
                sources = [valueType(declaration)]
            case .propertyTerm:
                sources = [propertyTerm(declaration)]
            case .individual:
                sources = namedIndividual(declaration)
            }
            return sources.map { DeclSyntax(stringLiteral: $0) }
        }
    }

    /// Reports, at the authored annotation, a related term written as a term
    /// of this ontology that the ontology does not declare: `Fauna.Habitatt`.
    private func diagnoseUndeclaredTerms() {
        for declaration in ontology.declarations {
            for annotation in declaration.annotations {
                guard let spelling = annotation.term,
                      let name = ontology.resolve(spelling).localName,
                      ontology.declaration(named: name) == nil else { continue }
                context.diagnose(Diagnostic(
                    node: annotation.syntax,
                    message: OntologyDiagnostic.undeclaredTerm(spelling, ontology: ontology.typeName)
                ))
            }
        }
    }

    // MARK: - Shapes

    private func alias(_ declaration: ParsedEntity, form: String, isGeneric: Bool) -> String {
        let name = SwiftIdentifier.escaped(declaration.name)
        let documentation = Documentation.docComment(for: declaration)
        if isGeneric {
            return "\(documentation)public typealias \(name)<Term> = RDFCore.`\(form)`<Term>"
        }
        return "\(documentation)public typealias \(name) = RDFCore.`\(form)`"
    }

    private func classProtocol(_ declaration: ParsedEntity) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let requirements = model.ownRequirements(of: declaration.name).map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    var \(requirement.name): \(requirement.storageType) { get }"
        }.joined(separator: "\n\n")

        let protocolSource = """
        \(Documentation.docComment(for: declaration))public protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {\(requirements.isEmpty ? "}" : "\n" + requirements + "\n}")
        """
        guard model.knowsAllRequirements(of: declaration.name) else { return [protocolSource] }

        let individualName = SwiftIdentifier.sanitized(declaration.name) + "Individual"
        if ontology.declaration(named: individualName) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.individualTypeCollides(name: individualName, className: declaration.name)
            ))
            return [protocolSource]
        }
        let individual = individualClass(
            documentation: "/// An individual of ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``.\n",
            access: "public",
            name: individualName,
            conformances: ["\(ontology.typeName).\(name)"],
            requirements: model.storedRequirements(ofClasses: [declaration.name]),
            metadata: Documentation.metadata(for: declaration, in: ontology),
            isNamed: false
        )
        return [protocolSource, individual]
    }

    private func namedIndividual(_ declaration: ParsedEntity) -> [String] {
        var classes: [String] = []
        var localClasses: [String] = []
        for annotation in declaration.annotations("Type") {
            guard let spelling = annotation.term else { continue }
            if let local = ontology.resolve(spelling).localName, ontology.declaration(named: local) == nil { return [] }
            guard model.knowsAllRequirements(ofSpelling: spelling) else {
                context.diagnose(Diagnostic(node: annotation.syntax, message: OntologyDiagnostic.individualOfForeignClass(spelling)))
                return []
            }
            let reference = ontology.resolve(spelling)
            let qualified = ontology.spelling(of: reference)
            if !classes.contains(qualified) { classes.append(qualified) }
            if let local = reference.localName { localClasses.append(local) }
        }
        if classes.isEmpty { classes = ["RDFCore.Resource"] }

        let name = SwiftIdentifier.escaped(declaration.name)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Individual"
        let individual = individualClass(
            documentation: "",
            access: "private",
            name: typeName,
            conformances: classes,
            requirements: model.storedRequirements(ofClasses: localClasses),
            metadata: Documentation.metadata(for: declaration, in: ontology),
            isNamed: true
        )
        let constant = """
        \(Documentation.docComment(for: declaration))public static let \(name): any \(classes.joined(separator: " & ")) = \(typeName)()
        """
        return [constant, individual]
    }

    /// A final class whose instances are individuals of the given classes.
    ///
    /// Each property is a `let` holding an ``RDFCore/PropertyValues`` or
    /// ``RDFCore/PropertyValue``, which guard the values with a mutex, so the
    /// class is `Sendable` as checked by the compiler and every change to a
    /// property is atomic. An individual of a class is created in an
    /// ``RDFCore/IndividualGraph``, which owns its lifetime; a named
    /// individual is a static constant and belongs to no graph.
    private func individualClass(
        documentation: String,
        access: String,
        name: String,
        conformances: [String],
        requirements: [OntologyModel.PropertyRequirement],
        metadata: String,
        isNamed: Bool
    ) -> String {
        let memberAccess = access == "private" ? "fileprivate" : access
        let properties = requirements.map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    \(memberAccess) let \(requirement.name): \(requirement.storageType)"
        }.joined(separator: "\n\n")

        let initializer: String
        if isNamed {
            let assignments = requirements.map { "        self.\($0.name) = \($0.storageType)()" }.joined(separator: "\n")
            initializer = """
                fileprivate init() {\(assignments.isEmpty ? "}" : "\n" + assignments + "\n    }")
            """
        } else {
            let parameters = (["in graph: RDFCore.IndividualGraph"] + requirements.map {
                "\($0.name): \($0.declaredType) = \($0.emptyValue)"
            }).joined(separator: ", ")
            let assignments = requirements.map { "        self.\($0.name) = \($0.storageType)(\($0.name))" }
            let storages = requirements.map { "self.\($0.name)" }.joined(separator: ", ")
            initializer = """
                /// Creates an individual in a graph, with these property values.
                public init(\(parameters)) {
            \((assignments + ["        graph.insert(self, properties: [\(storages)])"]).joined(separator: "\n"))
                }
            """
        }

        return """
        \(documentation)\(access) final class \(name): \(conformances.joined(separator: ", ")) {
            \(memberAccess) static let metadata: any RDFCore.ContentMetadata = \(metadata)
        \(properties.isEmpty ? "" : "\n" + properties + "\n")
        \(initializer)
        }
        """
    }

    private func valueType(_ declaration: ParsedEntity) -> String {
        if let recursion = model.recursiveValueType(of: declaration.name) {
            context.diagnose(Diagnostic(
                node: recursion.property.syntax,
                message: OntologyDiagnostic.recursiveValue(property: recursion.property.name, type: recursion.type)
            ))
        }
        let requirements = model.ownRequirements(of: declaration.name)
        let storage = requirements.map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    public var \(requirement.name): \(requirement.declaredType)"
        }.joined(separator: "\n\n")
        let parameters = (["_ lexicalForm: String", "languageTag: String? = nil", "direction: RDFCore.TextDirection? = nil"]
            + requirements.map { "\($0.name): \($0.declaredType) = \($0.emptyValue)" }).joined(separator: ", ")
        let assignments = (["lexicalForm", "languageTag", "direction"] + requirements.map(\.name))
            .map { "        self.\($0) = \($0)" }.joined(separator: "\n")

        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.LiteralValue {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            /// The lexical form of this literal.
            public var lexicalForm: String

            /// The language tag of this literal, if it is a language-tagged string.
            public var languageTag: String?

            /// The base direction of this literal, if it is a directional language-tagged string.
            public var direction: RDFCore.TextDirection?
        \(storage.isEmpty ? "" : "\n" + storage + "\n")
            /// Creates a literal with this lexical form.
            public init(\(parameters)) {
        \(assignments)
            }

            /// Creates a literal from its lexical form.
            public init(stringLiteral lexicalForm: String) {
                self.init(lexicalForm)
            }
        }
        """
    }

    private func propertyTerm(_ declaration: ParsedEntity) -> String {
        var relations: [String] = []
        if let domain = declaration.term("Domain") {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(model.valueType(ofRange: domain))")
        }
        if let range = declaration.term("Range") {
            relations.append("    /// The type of this property's values.\n    public typealias Range = \(model.valueType(ofRange: range))")
        }
        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.Entity {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))
        \(relations.isEmpty ? "" : "\n" + relations.joined(separator: "\n\n"))
        }
        """
    }
}
