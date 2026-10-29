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
///   class (`Fauna.AnimalIndividual`) that conforms to the class protocol.
///   `@StoredRequirements` on each class protocol implements its
///   requirements for every individual type, in any module, so an
///   individual of a class that refines another ontology's class has that
///   class's properties too. Its instances are individuals of the class:
///   references, whose identity is the object, created in an
///   ``RDFCore/IndividualGraph`` that owns their lifetime.
/// - A named individual becomes a static constant of the ontology
///   (`Fauna.carnivore`), the one instance of a final class that conforms to
///   all of its classes.
/// - A datatype, `rdfs:Literal` and its subclasses become value types that
///   store the literal (``RDFCore/LiteralValue``).
/// - A property becomes a term type that names its `Domain` and `Range`. A
///   property that is no requirement of a class protocol here (its domain is
///   another ontology's class, or it has none) conforms to
///   ``RDFCore/PropertyTerm``, and a static subscript on the term reads and
///   writes its values for a subject of its domain.
/// - Every class and datatype also becomes a static constant that is the
///   class as a value (`Foaf.agentClass`), an individual of its `rdf:type`.
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
        var identifiers: [String: String] = [:]
        return ontology.declarations.flatMap { declaration -> [DeclSyntax] in
            guard generated.insert(declaration.name).inserted else {
                context.diagnose(Diagnostic(node: declaration.syntax, message: OntologyDiagnostic.duplicateDeclaration(declaration.name)))
                return []
            }
            let identifier = SwiftIdentifier.sanitized(declaration.name)
            if let other = identifiers[identifier] {
                context.diagnose(Diagnostic(
                    node: declaration.syntax,
                    message: OntologyDiagnostic.identifierCollides(declaration.name, with: other, identifier: identifier)
                ))
                return []
            }
            identifiers[identifier] = declaration.name
            if declaration.kind == .property, declaration.name == OntologyModel.reservedName, model.hasClassDomain(declaration) {
                context.diagnose(Diagnostic(node: declaration.syntax, message: OntologyDiagnostic.reservedPropertyName(declaration.name)))
            }
            guard let shape = model.shape(of: declaration.name) else { return [] }
            var sources: [String]
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
            if declaration.kind == .class || declaration.kind == .datatype {
                let valueName = OntologyModel.classValueName(of: declaration.name)
                if let other = ontology.declarations.first(where: { SwiftIdentifier.sanitized($0.name) == valueName }) {
                    context.diagnose(Diagnostic(
                        node: declaration.syntax,
                        message: OntologyDiagnostic.classValueCollides(name: valueName, className: declaration.name, with: other.name)
                    ))
                } else {
                    sources += classValue(declaration)
                }
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
                + "    var \(requirement.name): \(requirement.viewType) { get }"
        }.joined(separator: "\n\n")

        let protocolSource = """
        \(Documentation.docComment(for: declaration))@StoredRequirements
        public protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {\(requirements.isEmpty ? "}" : "\n" + requirements + "\n}")
        """
        guard model.hasIndividuals(declaration.name) else { return [protocolSource] }

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
        for annotation in declaration.annotations("Type") {
            guard let spelling = annotation.term else { continue }
            let reference = ontology.resolve(spelling)
            if let local = reference.localName, ontology.declaration(named: local) == nil { return [] }
            let qualified = ontology.spelling(of: reference)
            if !classes.contains(qualified) { classes.append(qualified) }
        }
        if classes.isEmpty { classes = ["RDFCore.Resource"] }

        let name = SwiftIdentifier.escaped(declaration.name)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Individual"
        let individual = individualClass(
            documentation: "",
            access: "private",
            name: typeName,
            conformances: classes,
            requirements: [],
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
    /// The class stores nothing but its ``RDFCore/Membership``: every
    /// requirement of its class protocols, from this ontology or another, is
    /// implemented by `@StoredRequirements` on that protocol and stored in
    /// the membership, guarded by a mutex. So the class is `Sendable` as
    /// checked by the compiler and every change to a property is atomic.
    ///
    /// An individual of a class is created in an ``RDFCore/IndividualGraph``
    /// and holds its membership: the graph lives while any of its
    /// individuals does. Its initializer takes the values of the properties
    /// declared in this ontology; properties inherited from another
    /// ontology's classes start empty. A named individual is a static
    /// constant, belongs to no graph and has fixed values, so nothing one
    /// graph asserts reaches another.
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
        var members: [String] = []
        members.append("    \(memberAccess) static let metadata: any RDFCore.ContentMetadata = \(metadata)")
        if isNamed {
            members.append("    \(memberAccess) let membership = RDFCore.Membership.fixed()")
            members.append("    fileprivate init() {}")
        } else {
            members.append("    /// This individual's place in its graph, which stores its property values.\n    public let membership: RDFCore.Membership")
            members.append("""
                private init(membership: RDFCore.Membership) {
                    self.membership = membership
                }
            """)
            let parameters = (["in graph: RDFCore.IndividualGraph"] + requirements.map {
                "\($0.name): \($0.declaredType) = \($0.emptyValue)"
            }).joined(separator: ", ")
            let assignments = requirements.map { requirement in
                requirement.isFunctional
                    ? "        self.\(requirement.name).replace(with: \(requirement.name))"
                    : "        self.\(requirement.name).append(contentsOf: \(requirement.name))"
            }
            let body = [
                "        self.init(membership: RDFCore.Membership(in: graph) { \(name)(membership: $0) })",
                "        graph.insert(self)",
            ] + assignments
            members.append("""
                /// Creates an individual in a graph, with these property values.
                public convenience init(\(parameters)) {
            \(body.joined(separator: "\n"))
                }
            """)
        }

        return """
        \(documentation)\(access) final class \(name): \((conformances + ["RDFCore.StoredIndividual"]).joined(separator: ", ")) {
        \(members.joined(separator: "\n\n"))
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
        let requirement = model.requirement(for: declaration)
        // A property that is no requirement of a class protocol here is
        // stored under its term, through a subscript on the term.
        let subjects = model.hasClassDomain(declaration) ? [] : model.subjectTypes(of: declaration)
        let isStored = !subjects.isEmpty
        var relations: [String] = []
        if isStored, !declaration.terms("Domain").isEmpty, subjects.count == 1 {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(subjects[0])")
        } else if let domain = model.domainType(of: declaration) {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(domain)")
        }
        if isStored || !declaration.terms("Range").isEmpty {
            relations.append("    /// The type of this property's values.\n    public typealias Range = \(requirement.valueType)")
        }
        var conformances = ["RDFCore.Entity"]
        if isStored {
            conformances.append("RDFCore.PropertyTerm")
            relations.append("    private init() {}")
            for subject in subjects {
                relations.append("""
                    /// The \(requirement.isFunctional ? "value" : "values") of this property for `subject`.
                    public static subscript(subject: \(subject)) -> \(requirement.viewType) {
                        \(requirement.isFunctional ? "RDFCore.PropertyValue" : "RDFCore.PropertyValues")(Self(), of: subject)
                    }
                """)
            }
        }
        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): \(conformances.joined(separator: ", ")) {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))
        \(relations.isEmpty ? "" : "\n" + relations.joined(separator: "\n\n"))
        }
        """
    }

    /// A static constant that stands for a class or datatype as a value: the
    /// one individual of the class's `rdf:type` that the class names, so a
    /// property whose range is a class of classes holds it.
    /// `ACL.agentClass` holds `Foaf.agentClass`, the class `foaf:Agent`.
    private func classValue(_ declaration: ParsedEntity) -> [String] {
        let name = OntologyModel.classValueName(of: declaration.name)
        let classes = model.classValueTypes(of: declaration)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Class"
        let individual = individualClass(
            documentation: "",
            access: "private",
            name: typeName,
            conformances: classes,
            requirements: [],
            metadata: Documentation.metadata(for: declaration, in: ontology),
            isNamed: true
        )
        let reference = "``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``"
        let constant = """
        /// The class \(reference) as a value, an individual of its `rdf:type`.
        public static let \(name): any \(classes.joined(separator: " & ")) = \(typeName)()
        """
        return [constant, individual]
    }
}
