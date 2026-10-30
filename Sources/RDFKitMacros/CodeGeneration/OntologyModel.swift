import SwiftSyntax

/// What each declared term becomes, and how classes, properties and
/// individuals relate in the generated code.
///
/// The model reads only the DSL's own forms and the types the annotations
/// name. What a term named from another module is, a class of individuals
/// or of literals, is resolved by the compiler through that module's
/// generated types (`RDF.LiteralIndividual.Member` for `Range(RDF.Literal)`),
/// never by a table of spellings or IRIs.
///
/// - A `Class` becomes a protocol, a storing protocol and a final class
///   whose instances are its members; a `Datatype` too, whose members are
///   literals. Each `SubClassOf` becomes a refinement, so an individual can
///   belong to several classes.
/// - A `Property` becomes a term type, and, when its `Domain` is a class of
///   this ontology, a value type that holds its values on an individual and
///   a storing protocol that gives the individual its accessor.
/// - An `Individual` becomes a Swift class that conforms to the storing
///   protocol of each class its `Type` gives, and an ontology member whose
///   value is the individual.
struct OntologyModel {
    enum Shape: Equatable {
        /// A class: its members are individuals.
        case `class`
        /// A datatype: its members are literals.
        case datatype
        /// A property term type.
        case property
        /// A named individual (`owl:NamedIndividual`).
        case individual
    }

    /// A property as a requirement of a class protocol.
    struct PropertyRequirement {
        /// The property declaration.
        let declaration: ParsedEntity
        /// The Swift type of one value, by the property's range.
        let memberType: TypeSyntax

        /// The property name as a Swift identifier.
        var name: TokenSyntax { .declared(declaration.name) }

        /// The values: a property has any number of them.
        var declaredType: TypeSyntax { .array(memberType) }
    }

    let ontology: ParsedOntology
    private var shapes: [String: Shape] = [:]

    init(ontology: ParsedOntology) {
        self.ontology = ontology
        for declaration in ontology.declarations where shapes[declaration.name] == nil {
            shapes[declaration.name] = switch declaration.kind {
            case .class: .class
            case .datatype: .datatype
            case .property: .property
            case .individual: .individual
            }
        }
    }

    func shape(of name: String) -> Shape? { shapes[name] }

    /// Whether a local name is a class or datatype of this ontology.
    func isClass(_ name: String) -> Bool {
        shapes[name] == .class || shapes[name] == .datatype
    }

    // MARK: - Classes

    /// The protocols a class protocol refines: those of its superclasses,
    /// here or in other modules, or `RDF.Resource` when it names none, since
    /// every resource is an `rdfs:Resource` (RDF 1.2 Semantics, rdfs4).
    func refinements(of className: String) -> [QualifiedName] {
        var result: [QualifiedName] = []
        for name in superclassNames(of: className) where !result.contains(name) {
            result.append(name)
        }
        return result.isEmpty ? [ClassNames.resource] : result
    }

    /// The storing protocols a class's storing protocol refines for its
    /// superclasses.
    func superclassStoring(of className: String) -> [QualifiedName] {
        refinements(of: className).map { ClassNames(qualifiedClass: $0).qualifiedStoring }
    }

    /// The properties whose `Domain` is this class, in declaration order.
    func ownRequirements(of className: String) -> [PropertyRequirement] {
        ontology.properties.compactMap { property in
            let domains = property.terms("Domain").compactMap { ontology.resolve($0).localName }
            guard domains.contains(className) else { return nil }
            return requirement(for: property)
        }
    }

    /// The Swift type of a member of a class of this ontology as a value.
    func memberType(ofClass name: String) -> TypeSyntax {
        shapes[name] == .datatype ? QualifiedName("RDFCore", "Literal").type : .any(ontology.name(of: .local(name)).type)
    }

    // MARK: - Properties

    func requirement(for property: ParsedEntity) -> PropertyRequirement {
        PropertyRequirement(
            declaration: property,
            memberType: property.term("Range").map(memberType(ofRange:)) ?? QualifiedName("RDFCore", "Value").type
        )
    }

    /// The Swift type of one value of a range: a member of the range class.
    /// A class of another module is resolved through the `Member` of its
    /// generated Swift class, so `Range(RDF.Literal)` is `RDFCore.Literal`
    /// and `Range(FOAF.Person)` is `any FOAF.Person`.
    func memberType(ofRange spelling: String) -> TypeSyntax {
        let reference = ontology.resolve(spelling)
        if let name = reference.localName, isClass(name) {
            return memberType(ofClass: name)
        }
        return ClassNames(qualifiedClass: ontology.name(of: reference)).qualifiedIndividual.appending("Member").type
    }

    /// Whether a property has a `Domain` that is a class of this ontology,
    /// so it is stored on that class's members.
    func isStored(_ property: ParsedEntity) -> Bool {
        property.terms("Domain").contains { spelling in
            guard let name = ontology.resolve(spelling).localName else { return false }
            return isClass(name)
        }
    }

    /// The names of the protocols a class's `SubClassOf` annotations name.
    private func superclassNames(of className: String) -> [QualifiedName] {
        guard let declaration = ontology.declaration(named: className) else { return [] }
        return declaration.terms("SubClassOf").compactMap { spelling in
            let reference = ontology.resolve(spelling)
            if let local = reference.localName, !isClass(local) { return nil }
            return ontology.name(of: reference)
        }
    }
}

/// The names `@Ontology` and `RDFTranslatorPlugin` give the Swift of a
/// class, `Animal`: its storing protocol `AnimalStoring` and its Swift class
/// `AnimalIndividual`; and of a property, `hasHabitat`: its value type
/// `hasHabitatValue` and storing protocol `hasHabitatStoring`.
struct ClassNames {
    /// The protocol of `rdfs:Resource`, which every class refines.
    static let resource = QualifiedName("RDF", "Resource")

    /// The qualifier, `Fauna`, when the class is named from its ontology.
    let qualifier: QualifiedName?
    let className: String

    init(className: String) {
        qualifier = nil
        self.className = className
    }

    /// The names for a class named `Fauna.Animal`.
    init(qualifiedClass: QualifiedName) {
        qualifier = qualifiedClass.qualifier
        className = SwiftIdentifier.sanitized(qualifiedClass.name)
    }

    var value: String { className + "Value" }
    var storing: String { className + "Storing" }
    var individual: String { className + "Individual" }
    var qualifiedStoring: QualifiedName { qualified(storing) }
    var qualifiedIndividual: QualifiedName { qualified(individual) }

    private func qualified(_ name: String) -> QualifiedName {
        qualifier?.appending(name) ?? QualifiedName(name)
    }
}
