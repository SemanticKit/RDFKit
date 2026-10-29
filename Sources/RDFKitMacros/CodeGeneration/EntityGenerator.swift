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
///   class with no superclass refines `RDFS.Resource`.
/// - Each class also gets a property set (`Fauna.AnimalProperties`) that
///   holds the values of the properties the protocol requires. An individual
///   keeps its sets in its ``RDFCore/IndividualProperties``, one of each
///   type, and `@ClassProtocol` implements each property on its set. So a
///   class can refine another ontology's class (`OWL.Class` refining
///   `RDFS.Class`) without knowing its properties, and an individual of
///   several classes stores each property once.
/// - The properties an ontology declares for another ontology's classes
///   (`rdfs:domain` for `RDF.Property`) become members of the ontology's
///   extension point `Q.Extending` wherever the individual is in the domain,
///   stored in `Q.ExtendingProperties`.
/// - Each class with individuals also gets an individual type, a final class
///   named after the class (`Fauna.AnimalIndividual`) that conforms to the
///   class protocol. Its instances are individuals of the class: references,
///   whose identity is the object, created in an ``RDFCore/IndividualGraph``
///   that owns their lifetime.
/// - A named individual becomes a static constant of the ontology
///   (`Fauna.carnivore`), the one instance of a final class that conforms to
///   all of its classes.
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
        let terms = ontology.declarations.flatMap { declaration -> [DeclSyntax] in
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

    /// The property set of a class protocol: a final class holding the
    /// values of the properties the protocol requires, which
    /// `@ClassProtocol` implements the properties on.
    private func propertySet(named name: String, documentation: String, properties: [OntologyModel.PropertyRequirement]) -> String {
        let members = properties.map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    public let \(requirement.name) = \(requirement.storageType)()"
        }
        let removals = properties.map { "        \($0.name).removeAll()" }
        return """
        \(documentation)
        \(ontology.access)final class \(name): RDFCore.PropertySet {
        \(members.joined(separator: "\n\n"))

            /// Creates the properties with no values.
            public init() {}

            /// Removes every value.
            public func removeAll() {
        \(removals.joined(separator: "\n"))
            }
        }
        """
    }

    /// The ontology's extension point, when it declares properties for
    /// classes of other ontologies: `rdfs:domain` for `RDF.Property`,
    /// `owl:equivalentClass` for `RDFS.Class`.
    ///
    /// Swift extends a protocol only from the module and the declarations a
    /// macro is attached to, so the properties cannot become members of
    /// `RDF.Property` itself. They become members of `Q.Extending` wherever
    /// the individual is in their domain. Every class this ontology declares
    /// refines `Q.Extending`, and `RDFS.Resource`, the class of everything,
    /// refines the extension points of RDF, RDFS and OWL, so every individual
    /// has their properties. Each property is named by a type alias of its
    /// domain and storage, which `@ClassProtocol` reads.
    private func extensionPoint() -> [String] {
        let foreign = model.foreignDomains()
        guard !foreign.isEmpty else { return [] }
        for name in [OntologyModel.extensionPoint, OntologyModel.extensionPoint + "Properties"] {
            if let declaration = ontology.declaration(named: name) {
                context.diagnose(Diagnostic(
                    node: declaration.syntax,
                    message: OntologyDiagnostic.generatedTypeCollides(name: name, className: OntologyModel.extensionPoint)
                ))
                return []
            }
        }
        var aliases: [String] = []
        var stored: [OntologyModel.PropertyRequirement] = []
        for (domain, properties) in foreign {
            for requirement in properties where !stored.contains(where: { $0.declaration.name == requirement.declaration.name }) {
                stored.append(requirement)
                aliases.append(Documentation.docComment(for: requirement.declaration, indent: "    ")
                    + "    typealias _\(SwiftIdentifier.sanitized(requirement.declaration.name)) = (any \(domain), \(requirement.storageType))")
            }
        }
        let protocolSource = """
        /// The individuals the properties \(ontology.typeName) declares for other ontologies' classes apply to.
        ///
        /// Each property is a member of an individual in its domain.
        @ClassProtocol
        \(ontology.access)protocol \(OntologyModel.extensionPoint): RDFCore.IndividualObject {
        \(aliases.joined(separator: "\n\n"))
        }
        """
        let set = propertySet(
            named: OntologyModel.extensionPoint + "Properties",
            documentation: "/// The values of the properties \(ontology.typeName) declares for other ontologies' classes.",
            properties: stored
        )
        return [protocolSource, set]
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
        let requirements = model.storedOwnRequirements(of: declaration.name).map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    var \(requirement.name): \(requirement.storageType) { get }"
        }
        let body = requirements.isEmpty ? "" : "\n" + requirements.joined(separator: "\n\n") + "\n"
        var sources = ["""
        \(Documentation.docComment(for: declaration))@ClassProtocol
        \(ontology.access)protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {\(body)}
        """]

        let setName = SwiftIdentifier.sanitized(declaration.name) + "Properties"
        if ontology.declaration(named: setName) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.generatedTypeCollides(name: setName, className: declaration.name)
            ))
            return sources
        }
        let stored = model.storedOwnRequirements(of: declaration.name)
        if !stored.isEmpty {
            sources.append(propertySet(
                named: setName,
                documentation: "/// The values of the properties of an individual of ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``.",
                properties: stored
            ))
        }

        guard model.hasIndividuals(declaration.name) else { return sources }
        let individualName = SwiftIdentifier.sanitized(declaration.name) + "Individual"
        if ontology.declaration(named: individualName) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.generatedTypeCollides(name: individualName, className: declaration.name)
            ))
            return sources
        }

        let parameters = model.storedRequirements(ofClasses: [declaration.name])
        let signature = (["in graph: RDFCore.IndividualGraph"] + parameters.map {
            "\($0.name): \($0.declaredType) = \($0.emptyValue)"
        }).joined(separator: ", ")
        let assignments = parameters.map { "        self.\($0.name).replace(with: \($0.name))" }
            + ["        graph.insert(self)"]
        sources.append("""
        /// An individual of ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``.
        public final class \(individualName): \(ontology.typeName).\(name) {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            /// The values of this individual's properties.
            public let individualProperties = RDFCore.IndividualProperties()

            /// Creates an individual in a graph, with these property values.
            public init(\(signature)) {
        \(assignments.joined(separator: "\n"))
            }
        }
        """)
        return sources
    }

    private func namedIndividual(_ declaration: ParsedEntity) -> [String] {
        var classes: [String] = []
        for annotation in declaration.annotations("Type") {
            guard let spelling = annotation.term else { continue }
            let reference = ontology.resolve(spelling)
            if let local = reference.localName, ontology.declaration(named: local) == nil { return [] }
            if let local = reference.localName, !model.hasIndividuals(local) || model.shape(of: local) != .classProtocol {
                context.diagnose(Diagnostic(node: annotation.syntax, message: OntologyDiagnostic.individualOfClassWithoutIndividuals(spelling)))
                return []
            }
            if reference.localName == nil {
                let canonical = ontology.canonical(spelling)
                guard canonical.contains("."), !BootstrapTerm.isNothing(canonical), !BootstrapTerm.isLiteral(canonical) else {
                    context.diagnose(Diagnostic(node: annotation.syntax, message: OntologyDiagnostic.individualOfClassWithoutIndividuals(spelling)))
                    return []
                }
            }
            let qualified = ontology.spelling(of: reference)
            if !classes.contains(qualified) { classes.append(qualified) }
        }
        if classes.isEmpty { classes = [BootstrapTerm.resource] }

        let name = SwiftIdentifier.escaped(declaration.name)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Individual"

        // A property that several of the individual's local classes require
        // has an implementation in each of their extensions; the individual
        // settles on one, on the set that stores the property.
        let localClasses = classes.compactMap { ontology.resolve($0).localName }
        var localKnown: [String] = []
        for local in localClasses + localClasses.flatMap(model.localAncestors(of:)) where !localKnown.contains(local) {
            localKnown.append(local)
        }
        let members = model.sharedRequirements(among: localKnown).compactMap { requirement -> String? in
            guard let owner = localKnown.first(where: { name in
                model.storedOwnRequirements(of: name).contains { $0.declaration.name == requirement.declaration.name }
            }) else { return nil }
            let set = "\(ontology.typeName).\(SwiftIdentifier.sanitized(owner))Properties"
            return """
                fileprivate var \(requirement.name): \(requirement.storageType) {
                    individualProperties[\\\(set).\(requirement.name)]
                }
            """
        }

        let individual = """
        private final class \(typeName): \(classes.joined(separator: ", ")) {
            fileprivate static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            fileprivate let individualProperties = RDFCore.IndividualProperties()

            fileprivate init() {}\(members.isEmpty ? "" : "\n\n" + members.joined(separator: "\n\n"))
        }
        """
        let constant = """
        \(Documentation.docComment(for: declaration))public static let \(name): any \(classes.joined(separator: " & ")) = \(typeName)()
        """
        return [constant, individual]
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
