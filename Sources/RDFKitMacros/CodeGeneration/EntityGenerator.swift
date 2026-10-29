import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Generates the Swift declarations for an ontology's terms.
///
/// - A class becomes a protocol (`Fauna.Animal`) with one requirement for
///   each property with the class as `Domain`: a subscript keyed by the
///   property's term type, `subscript(property: Fauna.hasHabitat)`, typed by
///   its `Range`: many values (`[any Fauna.Habitat]`) by default, at most one
///   (`(any Fauna.Diet)?`) for an `owl:FunctionalProperty`. Because the key is
///   the term type, the requirements of two ontologies' properties with the
///   same local name are different requirements. `@ClassProperties` gives each
///   one a default implementation and a named member, `animal.hasHabitat`.
///   `SubClassOf` becomes protocol refinement; a class with no superclass
///   refines ``RDFCore/Resource``.
/// - Each class also gets an individual type, a final class named after the
///   class (`Fauna.AnimalIndividual`) that conforms to the class protocol and
///   takes every property of its classes in its initializer. Its instances are
///   individuals of the class: references, whose identity is the object.
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
            case .alias(let form, let isGeneric):
                sources = alias(declaration, form: form, isGeneric: isGeneric)
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

    private func alias(_ declaration: ParsedEntity, form: String, isGeneric: Bool) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let documentation = Documentation.docComment(for: declaration)
        let alias = isGeneric
            ? "\(documentation)public typealias \(name)<Term> = RDFCore.`\(form)`<Term>"
            : "\(documentation)public typealias \(name) = RDFCore.`\(form)`"
        guard declaration.kind == .property, model.isRequirement(declaration) else { return [alias] }
        // The alias is an RDFCore annotation type, not a property term, so the
        // values of this property are kept under a key of their own.
        let requirement = model.requirement(for: declaration)
        let key = """
        /// The key under which an individual keeps its ``\(ontology.typeName)/\(SwiftIdentifier.sanitized(declaration.name))`` values.
        public struct \(BootstrapTerm.valuesKey(of: SwiftIdentifier.sanitized(declaration.name))): RDFCore.PropertyKey {
            public typealias Value = \(requirement.declaredType)

            public static var noValues: Value { \(requirement.emptyValue) }

            public init() {}
        }
        """
        return [alias, key]
    }

    private func classProtocol(_ declaration: ParsedEntity) -> [String] {
        let name = SwiftIdentifier.escaped(declaration.name)
        let requirements = model.ownRequirements(of: declaration.name).map { requirement in
            Documentation.docComment(for: requirement.declaration, indent: "    ")
                + "    subscript(property: \(keyType(of: requirement))) -> \(requirement.declaredType) { get set }"
        }.joined(separator: "\n\n")

        // Each requirement is a subscript keyed by the property's term type,
        // so requirements of two ontologies' properties never share a
        // witness, even when the properties have the same local name.
        // `@ClassProperties` gives every requirement a default implementation
        // that keeps the values in the individual's storage, so an individual
        // type of another ontology can conform to this protocol too, and adds
        // the named member (`alice.knows`) that reads through it.
        let protocolSource = """
        \(Documentation.docComment(for: declaration))@ClassProperties
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
            initializerAccess: "public"
        )
        return [protocolSource, individual]
    }

    private func namedIndividual(_ declaration: ParsedEntity) -> [String] {
        var classes: [String] = []
        var localClasses: [String] = []
        for annotation in declaration.annotations("Type") {
            guard let spelling = annotation.term else { continue }
            let reference = ontology.resolve(spelling)
            if let local = reference.localName, ontology.declaration(named: local) == nil { return [] }
            let qualified = BootstrapTerm.isResource(ontology.canonical(spelling)) ? "RDFCore.Resource" : ontology.spelling(of: reference)
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
            initializerAccess: "fileprivate"
        )
        let constant = """
        \(Documentation.docComment(for: declaration))public static let \(name): any \(classes.joined(separator: " & ")) = \(typeName)()
        """
        return [constant, individual]
    }

    /// A final class whose instances are individuals of the given classes.
    ///
    /// Its property values are kept in one ``RDFCore/IndividualStorage``,
    /// guarded by a mutex, so the class is `Sendable` as checked by the
    /// compiler. It implements no requirement itself: every requirement, of
    /// this ontology's classes and of other ontologies' classes they refine,
    /// has its default implementation from `@ClassProperties`, keyed by its
    /// own term type, so no member of the class can answer for another
    /// ontology's property.
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
        let parameters = requirements.map { "\($0.name): \($0.declaredType) = \($0.emptyValue)" }.joined(separator: ", ")
        // A property without values is not stored: storage answers no values
        // for a property it does not hold.
        let assignments = requirements.map { requirement in
            let condition = requirement.isFunctional ? "\(requirement.name) != nil" : "!\(requirement.name).isEmpty"
            return "        if \(condition) { propertyValues[\(key(of: requirement))] = \(requirement.name) }"
        }.joined(separator: "\n")

        return """
        \(documentation)\(access) final class \(name): \(conformances.joined(separator: ", ")) {
            \(memberAccess) static let metadata: any RDFCore.ContentMetadata = \(metadata)

            /// The individual's property values.
            \(memberAccess) let propertyValues = RDFCore.IndividualStorage()

            /// Creates an individual with these property values.
            \(initializerAccess) init(\(parameters)) {\(assignments.isEmpty ? "}" : "\n" + assignments + "\n    }")
        }
        """
    }

    /// The key expression under which an individual keeps a requirement's
    /// values: the property term, `Fauna.hasHabitat()`.
    private func key(of requirement: OntologyModel.PropertyRequirement) -> String {
        "\(keyType(of: requirement))()"
    }

    /// The type that keys a requirement's values: the property term,
    /// `Fauna.hasHabitat`, or the values key of a property whose term is an
    /// RDFCore alias, `RDFS._subClassOfValues`.
    private func keyType(of requirement: OntologyModel.PropertyRequirement) -> String {
        let property = SwiftIdentifier.sanitized(requirement.declaration.name)
        if case .alias = model.shape(of: requirement.declaration.name) {
            return "\(ontology.typeName).\(BootstrapTerm.valuesKey(of: property))"
        }
        return "\(ontology.typeName).\(requirement.name)"
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
        let requirement = model.requirement(for: declaration)
        let subjects = model.subjectTypes(of: declaration)
        var relations: [String] = []
        if !declaration.terms("Domain").isEmpty {
            relations.append("    /// The type this property applies to.\n    public typealias Domain = \(model.domainType(of: declaration))")
        }
        if !declaration.terms("Range").isEmpty {
            relations.append("    /// The type of this property's values.\n    public typealias Range = \(requirement.valueType)")
        }
        relations.append("""
            /// The values one subject has for this property.
            public typealias Value = \(requirement.declaredType)

            /// No values.
            public static var noValues: Value { \(requirement.emptyValue) }

            /// The property term, the key of its values in an individual's storage.
            public init() {}
        """)
        // One subscript for each domain, and one for a subject in all of them,
        // which is more specific than each.
        var subscriptSubjects = subjects
        if subjects.count > 1 {
            subscriptSubjects.append("any " + subjects.map { String($0.dropFirst(4)) }.joined(separator: " & "))
        }
        for subject in subscriptSubjects {
            relations.append("""
                /// The values `subject` has for this property.
                public static subscript(subject: \(subject)) -> Value {
                    get { subject.propertyValues[Self()] }
                    set { subject.propertyValues[Self()] = newValue }
                }
            """)
        }
        return """
        \(Documentation.docComment(for: declaration))public struct \(SwiftIdentifier.escaped(declaration.name)): RDFCore.PropertyTerm {
            public static let metadata: any RDFCore.ContentMetadata = \(Documentation.metadata(for: declaration, in: ontology))

        \(relations.joined(separator: "\n\n"))
        }
        """
    }
}
