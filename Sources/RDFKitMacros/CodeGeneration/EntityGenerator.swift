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
///   ``RDFCore/Resource``.
/// - Each class also gets an individual type, a final class named after the
///   class (`Fauna.AnimalIndividual`) that conforms to the class protocol and
///   stores every requirement. Its instances are individuals of the class:
///   references, whose identity is the object.
/// - A named individual becomes a static constant of the ontology
///   (`Fauna.carnivore`), the one instance of a final class that conforms to
///   all of its classes.
/// - A datatype, `rdfs:Literal` and its subclasses become value types.
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
            case .alias(let form):
                sources = [alias(declaration, form: form)]
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

    private func alias(_ declaration: ParsedEntity, form: String) -> String {
        let name = SwiftIdentifier.escaped(declaration.name)
        let documentation = Documentation.docComment(for: declaration)
        return "\(documentation)public typealias \(name) = RDFCore.`\(form)`"
    }

    private func classProtocol(_ declaration: ParsedEntity) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let requirements = model.ownRequirements(of: declaration.name).map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    var \(requirement.name): \(requirement.declaredType) { get set }"
        }.joined(separator: "\n\n")

        let protocolSource = """
        \(Documentation.docComment(for: declaration))public protocol \(name): \(model.refinements(of: declaration.name).joined(separator: ", ")) {\(requirements.isEmpty ? "}" : "\n" + requirements + "\n}")
        """
        let storingSources = storing(declaration)
        guard model.knowsAllRequirements(of: declaration.name) else { return [protocolSource] + storingSources }

        let individualName = SwiftIdentifier.sanitized(declaration.name) + "Individual"
        if ontology.declaration(named: individualName) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.individualTypeCollides(name: individualName, className: declaration.name)
            ))
            return [protocolSource] + storingSources
        }
        let individual = individualClass(
            documentation: "/// An individual of ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))``.\n",
            access: "public",
            name: individualName,
            conformances: ["\(ontology.typeName).\(name)"],
            requirements: model.storedRequirements(ofClasses: [declaration.name]),
            metadata: Documentation.metadata(for: declaration, in: ontology),
            initializerAccess: "public"
        )
        return [protocolSource, individual] + storingSources
    }

    /// The values struct and storing protocol of a class, by which an
    /// individual declared in another ontology or module that is typed with
    /// the class stores the class's property values.
    ///
    /// `Fauna.AnimalValues` holds the values of the class's own properties,
    /// those whose domain is the class. `Fauna.AnimalStoring` refines the
    /// class protocol and the storing protocols of its superclasses, whichever
    /// ontology declares them, and restates the class's own requirements.
    /// `@IndividualStoring` gives those requirements their accessors through
    /// ``RDFCore/ClassValuesStoring/withClassValues(_:)``. Each property is
    /// supplied by the storing protocol of its own class only, so an
    /// individual in two classes that share a superclass stores the
    /// superclass's properties once.
    private func storing(_ declaration: ParsedEntity) -> [String] {
        let base = SwiftIdentifier.sanitized(declaration.name)
        let names = StoringNames(className: base)
        for taken in [names.values, names.storing] where ontology.declaration(named: taken) != nil {
            context.diagnose(Diagnostic(
                node: declaration.syntax,
                message: OntologyDiagnostic.individualTypeCollides(name: taken, className: declaration.name)
            ))
            return []
        }
        let qualified = "\(ontology.typeName).\(SwiftIdentifier.escaped(declaration.name))"
        let requirements = model.ownRequirements(of: declaration.name)
        let fields = requirements.map { "    public var \($0.name): \($0.declaredType) = \($0.emptyValue)" }.joined(separator: "\n")
        let values = """
        /// The values of the properties of ``\(ontology.typeName)/\(base)`` that an individual stores.
        public struct \(names.values): RDFCore.ClassValues {
        \(fields.isEmpty ? "" : fields + "\n\n")    public init() {}
        }
        """
        var refinements = [qualified]
        for spelling in model.refinements(of: declaration.name) {
            let storing = BootstrapTerm.isResource(ontology.canonical(spelling))
                ? "RDFCore.ClassValuesStoring"
                : StoringNames(qualifiedClass: spelling).qualifiedStoring
            if !refinements.contains(storing) { refinements.append(storing) }
        }
        let restated = requirements.map { "    var \($0.name): \($0.declaredType) { get set }" }.joined(separator: "\n")
        let storingSource = """
        /// An individual of ``\(ontology.typeName)/\(base)`` that stores the values of its
        /// classes in an ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
        /// An individual of another ontology typed with the class conforms to it.
        @IndividualStoring
        public protocol \(names.storing): \(refinements.joined(separator: ", ")) {\(restated.isEmpty ? "" : "\n" + restated + "\n")}
        """
        return [values, storingSource]
    }

    /// A named individual: a static constant, the one instance of a private
    /// final class that conforms to the storing protocol of each of its
    /// classes, whichever ontology declares them (`rdf:type` relates a
    /// resource to any class, RDF 1.2 Semantics). The class keeps the values
    /// of all its classes and their superclasses in one
    /// ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``, so a
    /// property it has through two of its classes is one property.
    private func namedIndividual(_ declaration: ParsedEntity) -> [String] {
        var classes: [String] = []
        var conformances: [String] = []
        for annotation in declaration.annotations("Type") {
            guard let spelling = annotation.term else { continue }
            if let local = ontology.resolve(spelling).localName, ontology.declaration(named: local) == nil { return [] }
            let qualified = ontology.spelling(of: ontology.resolve(spelling))
            guard !classes.contains(qualified) else { continue }
            classes.append(qualified)
            conformances.append(BootstrapTerm.isResource(ontology.canonical(spelling))
                ? "RDFCore.ClassValuesStoring"
                : StoringNames(qualifiedClass: qualified).qualifiedStoring)
        }
        if classes.isEmpty {
            classes = ["RDFCore.Resource"]
            conformances = ["RDFCore.ClassValuesStoring"]
        }

        let name = SwiftIdentifier.escaped(declaration.name)
        let typeName = "_\(SwiftIdentifier.sanitized(declaration.name))Individual"
        let constant = """
        \(Documentation.docComment(for: declaration))public static let \(name): any \(classes.joined(separator: " & ")) = \(typeName)()
        """
        let individual = """
        private final class \(typeName): \(conformances.joined(separator: ", ")) {
            fileprivate static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

            private let values = RDFCore.IndividualStorage(RDFCore.IndividualValues())

            fileprivate init() {}

            /// Reads or changes this individual's values of one class under its lock.
            fileprivate func withClassValues<Values: RDFCore.ClassValues, Result: Sendable>(_ body: (inout Values) -> Result) -> Result {
                values.withLock { $0.withValues(body) }
            }
        }
        """
        return [constant, individual]
    }

    /// A final class whose instances are individuals of the given classes.
    ///
    /// Its property values are kept in one ``RDFCore/IndividualStorage``,
    /// guarded by a mutex, so the class is `Sendable` as checked by the
    /// compiler.
    private func individualClass(
        documentation: String,
        access: String,
        name: String,
        conformances: [String],
        requirements: [OntologyModel.PropertyRequirement],
        metadata: String,
        initializerAccess: String
    ) -> String {
        let memberAccess = access == "private" ? "fileprivate" : access
        let fields = requirements.map { "        var \($0.name): \($0.declaredType)" }.joined(separator: "\n")
        let parameters = requirements.map { "\($0.name): \($0.declaredType) = \($0.emptyValue)" }.joined(separator: ", ")
        let arguments = requirements.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
        let accessors = requirements.map { requirement in
            """
            \(Documentation.docComment(for: requirement.declaration, indent: "    "))    \(memberAccess) var \(requirement.name): \(requirement.declaredType) {
                    get { storage.withLock { $0.\(requirement.name) } }
                    set { storage.withLock { $0.\(requirement.name) = newValue } }
                }
            """
        }.joined(separator: "\n\n")

        let values = fields.isEmpty ? "    private struct Values: Sendable {}" : "    private struct Values: Sendable {\n\(fields)\n    }"
        return """
        \(documentation)\(access) final class \(name): \(conformances.joined(separator: ", ")) {
            \(memberAccess) static let metadata: any RDFCore.ContentMetadata = \(metadata)

        \(values)

            private let storage: RDFCore.IndividualStorage<Values>

            /// Creates an individual with these property values.
            \(initializerAccess) init(\(parameters)) {
                storage = RDFCore.IndividualStorage(Values(\(arguments)))
            }\(accessors.isEmpty ? "" : "\n\n" + accessors)
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

/// The names `@Ontology` gives a class's values struct and storing protocol:
/// `AnimalValues`, `AnimalStoring`.
struct StoringNames {
    /// The qualified class, `Fauna.Animal`, when it is named from another ontology.
    let qualifier: String?
    let className: String

    init(className: String) {
        qualifier = nil
        self.className = className
    }

    /// The names for a class spelled from another ontology, `Fauna.Animal`.
    init(qualifiedClass: String) {
        let components = qualifiedClass.split(separator: ".").map(String.init)
        qualifier = components.dropLast().joined(separator: ".")
        className = SwiftIdentifier.sanitized(components.last.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "`")) } ?? qualifiedClass)
    }

    var values: String { className + "Values" }
    var storing: String { className + "Storing" }
    var qualifiedValues: String { qualified(values) }
    var qualifiedStoring: String { qualified(storing) }

    private func qualified(_ name: String) -> String {
        guard let qualifier, !qualifier.isEmpty else { return name }
        return qualifier + "." + name
    }
}
