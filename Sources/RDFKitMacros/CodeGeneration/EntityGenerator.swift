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
///   class with no superclass refines `RDFS.Resource`, which refines
///   ``RDFCore/Resource``.
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
///   all of its classes, from this ontology or others.
/// - The properties an ontology declares for another ontology's classes
///   (`rdfs:domain` for `RDF.Property`) become members of the ontology's
///   extension point `Q.Extending` wherever the individual is in the domain.
/// - A datatype, `rdfs:Literal` and its subclasses become value types that
///   store the literal (``RDFCore/LiteralValue``).
/// - A property becomes a term type that names its `Domain` and `Range`. The
///   properties the DSL is written with (`rdfs:label`, `rdfs:domain`, ...)
///   are also annotation types, which content is built from.
/// - RDFKit's own `Namespace` and `Prefix` become aliases of the RDFCore
///   values that content is written with.
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
        let terms = ontology.declarations.flatMap { declaration -> [DeclSyntax] in
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
            if declaration.kind == .property, declaration.name == OntologyModel.reservedName, !model.classDomains(of: declaration).isEmpty {
                context.diagnose(Diagnostic(node: declaration.syntax, message: OntologyDiagnostic.reservedPropertyName(declaration.name)))
            }
            guard let shape = model.shape(of: declaration.name) else { return [] }
            let sources: [String]
            switch shape {
            case .alias(let form, let isGeneric):
                sources = [alias(declaration, form: form, isGeneric: isGeneric)]
            case .classProtocol:
                sources = classProtocol(declaration)
            case .value:
                sources = [valueType(declaration)]
            case .propertyTerm:
                sources = [propertyTerm(declaration, form: nil)]
            case .annotation(let form):
                sources = [propertyTerm(declaration, form: form)]
            case .individual:
                sources = namedIndividual(declaration)
            }
            return sources.map { DeclSyntax(stringLiteral: $0) }
        }
        return terms + extensionPoint().map { DeclSyntax(stringLiteral: $0) }
    }

    /// The ontology's extension point, when it declares properties for
    /// classes of other ontologies: `rdfs:domain` for `RDF.Property`,
    /// `owl:equivalentClass` for `RDFS.Class`.
    ///
    /// Swift lets a macro extend only the declaration it is attached to, so
    /// the properties cannot become requirements or members of `RDF.Property`
    /// itself. They become members of `Q.Extending` wherever the individual
    /// is in their domain. Every class this ontology declares without a local
    /// superclass refines `Q.Extending`, and `RDFS.Resource`, the class of
    /// everything, refines the extension points of RDF, RDFS and OWL, so
    /// every individual has their properties. Each property is named by a
    /// type alias of its domain and value view, which `@StoredRequirements`
    /// reads. The extension point requires the individual's membership, so
    /// the members work on existentials such as `any RDF.Property`.
    private func extensionPoint() -> [String] {
        let foreign = model.foreignDomains()
        guard !foreign.isEmpty else { return [] }
        if let declaration = ontology.declaration(named: OntologyModel.extensionPoint) {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.generatedTypeCollides(name: OntologyModel.extensionPoint, className: OntologyModel.extensionPoint)
            ))
            return []
        }
        var aliases: [String] = []
        var named: Set<String> = []
        for (domain, properties) in foreign {
            for requirement in properties where named.insert(requirement.declaration.name).inserted {
                aliases.append(Documentation.docComment(for: requirement.declaration, indent: "    ")
                    + "    typealias _\(SwiftIdentifier.sanitized(requirement.declaration.name)) = (any \(domain), \(requirement.viewType))")
            }
        }
        return ["""
        /// The individuals the properties \(ontology.typeName) declares for other ontologies' classes apply to.
        ///
        /// Each such property is a member of every individual in its domain.
        @StoredRequirements
        \(ontology.access)protocol \(OntologyModel.extensionPoint): RDFCore.Resource {
            /// The individual's place in its graph, which stores its property values.
            var \(OntologyModel.reservedName): RDFCore.Membership { get }

        \(aliases.joined(separator: "\n\n"))
        }
        """]
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
        // A property that two of the class's local superclasses require is
        // required again, so this class's implementation settles which one
        // an individual uses.
        let requirements = model.storedOwnRequirements(of: declaration.name).map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    var \(requirement.name): \(requirement.viewType) { get }"
        }.joined(separator: "\n\n")

        let protocolSource = """
        \(Documentation.docComment(for: declaration))@StoredRequirements
        \(ontology.access)protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {\(requirements.isEmpty ? "}" : "\n" + requirements + "\n}")
        """
        guard model.hasIndividuals(declaration.name) else { return [protocolSource] }

        let individualName = SwiftIdentifier.sanitized(declaration.name) + "Individual"
        if ontology.declaration(named: individualName) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.generatedTypeCollides(name: individualName, className: declaration.name)
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
            let canonical = ontology.canonical(spelling)
            let isClass = reference.localName.map { model.shape(of: $0) == .classProtocol && model.hasIndividuals($0) }
                ?? (canonical.contains(".") && !BootstrapTerm.isNothing(canonical) && !BootstrapTerm.isLiteral(canonical))
            guard isClass else {
                context.diagnose(Diagnostic(node: annotation.syntax, message: OntologyDiagnostic.individualOfClassWithoutIndividuals(spelling)))
                return []
            }
            let qualified = ontology.spelling(of: reference)
            if !classes.contains(qualified) { classes.append(qualified) }
        }
        if classes.isEmpty { classes = [BootstrapTerm.resource] }

        // A property that several of the individual's local classes require
        // has an implementation in each of their extensions; the individual
        // implements it itself.
        let localClasses = classes.compactMap { ontology.resolve($0).localName }
        var localKnown: [String] = []
        for local in localClasses + localClasses.flatMap(model.localAncestors(of:)) where !localKnown.contains(local) {
            localKnown.append(local)
        }
        let shared = model.sharedRequirements(among: localKnown)

        let name = SwiftIdentifier.escaped(declaration.name)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Individual"
        let individual = individualClass(
            documentation: "",
            access: "private",
            name: typeName,
            conformances: classes,
            requirements: shared,
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
            // The properties several of its classes require, implemented once.
            members += requirements.map { requirement in
                let form = requirement.isFunctional ? "RDFCore.PropertyValue" : "RDFCore.PropertyValues"
                return """
                    fileprivate var \(requirement.name): \(requirement.viewType) {
                        \(form)(\\Self.\(requirement.name), of: membership)
                    }
                """
            }
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

    /// The term type of a property. A property the DSL is written with is
    /// also an annotation: `RDFS.label("Animal")`, `RDFS.domain<Fauna.Animal>()`.
    private func propertyTerm(_ declaration: ParsedEntity, form: BootstrapTerm.AnnotationForm?) -> String {
        var relations: [String] = []
        if let domain = declaration.term("Domain") {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(model.valueType(ofRange: domain))")
        }
        if let range = declaration.term("Range") {
            relations.append("    /// The type of this property's values.\n    public typealias Range = \(model.valueType(ofRange: range))")
        }
        let metadata = Documentation.metadata(for: declaration, in: ontology)
        let name = SwiftIdentifier.escaped(declaration.name)
        var header = "public struct \(name): RDFCore.Entity"
        var members = ["    public static let metadata: any RDFCore.ContentMetadata = \(metadata)"]
        switch form {
        case nil:
            break
        case .text:
            header = "public struct \(name): RDFCore.Annotation"
            members.append("    /// The annotation text.\n    public let text: String\n\n    public init(_ text: String) {\n        self.text = text\n    }")
        case .document:
            header = "public struct \(name): RDFCore.Annotation"
            members.append("    /// The address of the document, which readers dereference.\n    public let document: IRIKit.IRI\n\n    public init(_ document: IRIKit.IRI) {\n        self.document = document\n    }")
        case .flag:
            header = "public struct \(name): RDFCore.Annotation"
            members.append("    public init() {}")
        case .term:
            // A generic type cannot store a static property, so the metadata
            // of a term annotation is computed.
            header = "public struct \(name)<Term>: RDFCore.TermAnnotation"
            members = ["    public static var metadata: any RDFCore.ContentMetadata {\n        \(metadata)\n    }", "    public init() {}"]
        }
        return """
        \(Documentation.docComment(for: declaration))\(header) {
        \((members + relations).joined(separator: "\n\n"))
        }
        """
    }
}
