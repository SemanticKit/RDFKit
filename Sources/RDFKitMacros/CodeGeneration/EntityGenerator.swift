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
///   property whose domain is a class of another ontology, or
///   `rdfs:Resource`, is no requirement of that class protocol; its term type
///   has `values(of:)` (`value(of:)` when functional) for any stored
///   individual of the domain.
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
            if declaration.kind == .property { diagnoseDomain(of: declaration) }
            guard let shape = model.shape(of: declaration.name) else { return [] }
            let sources: [String]
            switch shape {
            case .alias(let form, let isGeneric):
                sources = [alias(declaration, form: form, isGeneric: isGeneric)] + aliasAccessorCheck(declaration)
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

    /// Reports a property no individual can have: one named like the
    /// membership every individual keeps, or one whose domain is not a class.
    private func diagnoseDomain(of property: ParsedEntity) {
        if case .failure(.notAClass(let spelling))? = model.domainAccess(for: property) {
            let annotation = property.annotations("Domain").first { $0.term == spelling }
            context.diagnose(Diagnostic(
                node: annotation?.syntax ?? property.syntax,
                message: OntologyDiagnostic.domainIsNotAClass(property: property.name, domain: spelling)
            ))
        }
        if property.name == OntologyModel.reservedName, model.hasClassDomain(property) {
            context.diagnose(Diagnostic(node: property.syntax, message: OntologyDiagnostic.reservedPropertyName(property.name)))
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
        var relations: [String] = []
        if let domain = declaration.term("Domain") {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(model.valueType(ofRange: domain))")
        }
        if let range = declaration.term("Range") {
            relations.append("    /// The type of this property's values.\n    public typealias Range = \(model.valueType(ofRange: range))")
        }
        if case .success(let access)? = model.domainAccess(for: declaration) {
            relations.append(accessor(access))
        }
        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.Entity {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))
        \(relations.isEmpty ? "" : "\n" + relations.joined(separator: "\n\n"))
        }
        """
    }

    /// For a property RDFCore provides (`rdfs:label` is `RDFCore.Label`)
    /// whose domain is a class of another ontology, or `rdfs:Resource`: a
    /// check that the accessor RDFKit gives that RDFCore type reads values
    /// of the declared domain and range. The RDFCore type cannot name the
    /// range, which this ontology declares, and a macro cannot extend it, so
    /// RDFKit writes its `values(of:)`; this keeps the declaration the source
    /// of truth, because a mismatch does not compile.
    private func aliasAccessorCheck(_ declaration: ParsedEntity) -> [String] {
        guard declaration.kind == .property, case .success(let access)? = model.domainAccess(for: declaration) else { return [] }
        let requirement = access.requirement
        let subject = (access.domains + ["RDFCore.StoredIndividual"]).filter { $0 != "RDFCore.Resource" }
        let method = requirement.isFunctional ? "value" : "values"
        let name = SwiftIdentifier.sanitized(declaration.name)
        return ["""
        private static func _\(name)Accessor(of individual: some \(subject.joined(separator: " & "))) -> \(requirement.viewType) {
            \(ontology.typeName).\(SwiftIdentifier.escaped(declaration.name)).\(method)(of: individual)
        }
        """]
    }

    /// The accessor a property term type has when the property's domain is
    /// a class of another ontology, or `rdfs:Resource`:
    ///
    ///     OWL.equivalentClass.values(of: someClass).append(otherClass)
    ///     RDFS.label.values(of: lion).append("Lion")
    ///
    /// Such a property cannot be a requirement of a protocol another
    /// ontology declares, and an extension of that protocol would be a
    /// file-scope declaration, which a macro can only write for the type it
    /// is attached to. So the property's own type reads and changes the
    /// values of any stored individual of its domain, in any module. The
    /// values are stored under the property term type.
    private func accessor(_ access: OntologyModel.DomainAccess) -> String {
        let requirement = access.requirement
        let subject = (access.domains + ["RDFCore.StoredIndividual"]).filter { $0 != "RDFCore.Resource" }
        if requirement.isFunctional {
            return """
                /// The value of this property of an individual.
                public static func value(of individual: some \(subject.joined(separator: " & "))) -> \(requirement.viewType) {
                    propertyValue(of: individual)
                }
            """
        }
        return """
            /// The values of this property of an individual.
            public static func values(of individual: some \(subject.joined(separator: " & "))) -> \(requirement.viewType) {
                propertyValues(of: individual)
            }
        """
    }
}
