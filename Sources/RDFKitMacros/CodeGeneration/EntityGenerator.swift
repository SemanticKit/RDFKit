import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Generates the Swift declarations for an ontology's terms.
///
/// - A class becomes a protocol (`Fauna.Animal`) whose requirements are the
///   properties with the class as `Domain`, typed by their `Range`: many
///   values (`[any Fauna.Habitat]`) by default, at most one
///   (`(any Fauna.Diet)?`) for an `owl:FunctionalProperty`. `SubClassOf`
///   becomes protocol refinement; a class with no superclass refines
///   `RDFS.Resource`.
/// - Each class gets a values struct (`Fauna.AnimalValues`) holding its own
///   properties and a slot for each class it refines, and the protocol
///   requires an accessor for each. `@ClassProtocol` implements the
///   properties on those values, so a class can refine another ontology's
///   class (`OWL.Class` refining `RDFS.Class`) without knowing its properties.
/// - Each class with individuals also gets an individual type, a final class
///   named after the class (`Fauna.AnimalIndividual`) that conforms to the
///   class protocol and keeps its values behind a lock. Its instances are
///   individuals of the class: references, whose identity is the object.
/// - A named individual becomes a static constant of the ontology
///   (`Fauna.carnivore`), the one instance of a final class that conforms to
///   all of its classes.
/// - A datatype, `rdfs:Literal` and its subclasses become value types.
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
                sources = [propertyTerm(declaration, form: nil)]
            case .annotation(let form):
                sources = [propertyTerm(declaration, form: form)]
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
        let own = model.storage(of: declaration.name)
        let ancestors = model.ancestorStorages(of: declaration.name)
        let stored = model.storedOwnRequirements(of: declaration.name)

        // The properties the class requires, then the values it stores for
        // itself and for each class it refines. `@ClassProtocol` implements
        // the properties and the ancestors' accessors on top of the class's
        // own accessor.
        var requirements = stored.map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    var \(requirement.name): \(requirement.declaredType) { get set }"
        }
        requirements.append("    /// Reads or changes the stored values of this class's properties.\n    \(own.accessorSignature)")
        requirements += ancestors.map { "    /// Reads or changes the stored values of ``\($0.classSpelling.replacingOccurrences(of: ".", with: "/"))``.\n    \($0.accessorSignature)" }

        let protocolSource = """
        \(Documentation.docComment(for: declaration))@ClassProtocol
        \(ontology.access)protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {
        \(requirements.joined(separator: "\n\n"))
        }
        """
        var sources = [protocolSource]

        if let collision = [own.localValuesName].first(where: { ontology.declaration(named: $0) != nil }) {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.generatedTypeCollides(name: collision, className: declaration.name)
            ))
            return sources
        }
        let fields = stored.map { "    var \($0.name): \($0.declaredType) = \($0.emptyValue)" }
            + ancestors.map { "    var \($0.slot) = \($0.valuesType)()" }
        sources.append("""
        /// The stored property values of an individual of ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``.
        public struct \(own.localValuesName): Sendable {
        \(fields.isEmpty ? "" : fields.joined(separator: "\n") + "\n\n")    /// No values.
            public init() {}
        }
        """)

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
        let assignments = parameters.map { requirement in
            let path = model.slot(of: requirement, inValuesOf: declaration.name).map { "values.\($0)." } ?? "values."
            return "        \(path)\(requirement.name) = \(requirement.name)"
        }
        let initializerBody = assignments.isEmpty
            ? "        storage = RDFCore.IndividualStorage(\(own.valuesType)())"
            : "        var values = \(own.valuesType)()\n" + assignments.joined(separator: "\n") + "\n        storage = RDFCore.IndividualStorage(values)"
        sources.append("""
        /// An individual of ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``.
        public final class \(individualName): \(ontology.typeName).\(name) {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            private let storage: RDFCore.IndividualStorage<\(own.valuesType)>

            /// Creates an individual with these property values.
            public init(\(parameters.map { "\($0.name): \($0.declaredType) = \($0.emptyValue)" }.joined(separator: ", "))) {
        \(initializerBody)
            }

            /// Reads or changes this individual's property values while holding its lock.
            public \(own.accessorSignature) {
                storage.withLock(body)
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
                guard ClassStorage(spelling: spelling) != nil, !BootstrapTerm.isNothing(ontology.canonical(spelling)) else {
                    context.diagnose(Diagnostic(node: annotation.syntax, message: OntologyDiagnostic.individualOfClassWithoutIndividuals(spelling)))
                    return []
                }
            }
            let qualified = ontology.spelling(of: reference)
            if !classes.contains(qualified) { classes.append(qualified) }
        }
        if classes.isEmpty { classes = [BootstrapTerm.resource] }

        let storages = model.storages(ofClassSpellings: classes)
        let name = SwiftIdentifier.escaped(declaration.name)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Individual"

        // The individual keeps one slot per class it belongs to, and answers
        // every class's accessor itself, so that classes sharing an ancestor
        // share one value for each of its properties.
        let fields = storages.map { "        var \($0.slot) = \($0.valuesType)()" }
        var members = storages.map { storage in
            """
                fileprivate \(storage.accessorSignature) {
                    storage.withLock { body(&$0.\(storage.slot)) }
                }
            """
        }
        let localClasses = classes.compactMap { ontology.resolve($0).localName }
        var localKnown: [String] = []
        for local in localClasses + localClasses.flatMap(model.localAncestors(of:)) where !localKnown.contains(local) {
            localKnown.append(local)
        }
        for requirement in model.sharedRequirements(among: localKnown) {
            guard let owner = localKnown.first(where: { model.storedOwnRequirements(of: $0).contains { $0.declaration.name == requirement.declaration.name } }) else { continue }
            let slot = model.storage(of: owner).slot
            members.append("""
                fileprivate var \(requirement.name): \(requirement.declaredType) {
                    get { storage.withLock { $0.\(slot).\(requirement.name) } }
                    set { storage.withLock { $0.\(slot).\(requirement.name) = newValue } }
                }
            """)
        }

        let individual = """
        private final class \(typeName): \(classes.joined(separator: ", ")) {
            fileprivate static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            private struct Values: Sendable {\(fields.isEmpty ? "" : "\n" + fields.joined(separator: "\n") + "\n    ")}

            private let storage = RDFCore.IndividualStorage(Values())

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
        let parameters = requirements.map { "\($0.name): \($0.declaredType) = \($0.emptyValue)" }.joined(separator: ", ")
        let assignments = requirements.map { "        self.\($0.name) = \($0.name)" }.joined(separator: "\n")

        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.Entity {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))
        \(storage.isEmpty ? "" : "\n" + storage + "\n")
            public init(\(parameters)) {\(assignments.isEmpty ? "}" : "\n" + assignments + "\n    }")
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
