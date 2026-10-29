/// What each declared term becomes, and how classes, properties and
/// individuals relate in the generated code.
///
/// - A `Class` becomes a protocol. Its requirements are the properties whose
///   `Domain` is the class, and each `SubClassOf` becomes a refinement, so an
///   individual can belong to several classes. `rdfs:Literal` and its
///   subclasses are the exception: literals have no identity, so they are
///   value types.
/// - A `Datatype` becomes a value type.
/// - An `Individual` becomes the one instance of a final class that conforms
///   to the protocols of its classes.
/// - A `Property` becomes a term type that names its `Domain` and `Range`.
struct OntologyModel {
    enum Shape: Equatable {
        /// A term RDFCore already provides.
        case alias(form: String, isGeneric: Bool)
        /// A class of individuals: a protocol.
        case classProtocol
        /// A datatype or literal class: a value type.
        case value
        /// A property term type.
        case propertyTerm
        /// A named individual.
        case individual
    }

    /// A property as a requirement of a class protocol or a stored property
    /// of a value type.
    struct PropertyRequirement {
        /// The property declaration.
        let declaration: ParsedEntity
        /// The Swift type of one value: the range's generated type.
        let valueType: String
        /// Whether the property is an `owl:FunctionalProperty`: at most one value.
        let isFunctional: Bool

        /// The property name as a Swift identifier.
        var name: String { SwiftIdentifier.escaped(declaration.name) }

        /// The values as a plain Swift value: an array by default, an
        /// optional for a functional property. A value type stores this, and
        /// an individual's initializer takes it.
        var declaredType: String {
            guard isFunctional else { return "[\(valueType)]" }
            return valueType.hasPrefix("any ") ? "(\(valueType))?" : "\(valueType)?"
        }

        /// The storage of the values on an individual: many values by
        /// default, at most one for a functional property, guarded by a mutex
        /// so that every change is atomic.
        var storageType: String {
            isFunctional ? "RDFCore.PropertyValue<\(valueType)>" : "RDFCore.PropertyValues<\(valueType)>"
        }

        /// No values.
        var emptyValue: String { isFunctional ? "nil" : "[]" }
    }

    let ontology: ParsedOntology
    private var shapes: [String: Shape] = [:]

    init(ontology: ParsedOntology) {
        self.ontology = ontology
        for declaration in ontology.declarations where shapes[declaration.name] == nil {
            shapes[declaration.name] = shape(computing: declaration)
        }
    }

    func shape(of name: String) -> Shape? { shapes[name] }

    // MARK: - Classes

    /// The protocols a class protocol refines: its local and foreign
    /// superclasses, or ``RDFCore/Resource`` when it declares none.
    func refinements(of className: String) -> [String] {
        var result: [String] = []
        for spelling in superclassSpellings(of: className) where !result.contains(spelling) {
            result.append(spelling)
        }
        return result.isEmpty ? ["RDFCore.Resource"] : result
    }

    /// Whether every class a class refines, transitively, is declared in this
    /// ontology or is `rdfs:Resource`, so that the macro knows every
    /// requirement an individual of the class must store. `owl:Nothing` and
    /// its subclasses have no individuals, so they have no individual type.
    func knowsAllRequirements(of className: String) -> Bool {
        var visited: Set<String> = []
        var pending = [className]
        while let current = pending.popLast() {
            guard visited.insert(current).inserted, let declaration = ontology.declaration(named: current) else { continue }
            if BootstrapTerm.isNothing("\(ontology.typeName).\(current)") { return false }
            for spelling in declaration.terms("SubClassOf") {
                let canonical = ontology.canonical(spelling)
                if BootstrapTerm.isResource(canonical) { continue }
                if BootstrapTerm.isNothing(canonical) { return false }
                guard let name = ontology.resolve(spelling).localName, shapes[name] == .classProtocol else { return false }
                pending.append(name)
            }
        }
        return true
    }

    /// Whether a class spelling, local or foreign, has an individual type
    /// this macro can generate.
    func knowsAllRequirements(ofSpelling spelling: String) -> Bool {
        if BootstrapTerm.isResource(ontology.canonical(spelling)) { return true }
        guard let name = ontology.resolve(spelling).localName, shapes[name] == .classProtocol else { return false }
        return knowsAllRequirements(of: name)
    }

    /// The properties whose `Domain` is this class, in declaration order.
    func ownRequirements(of className: String) -> [PropertyRequirement] {
        ontology.properties.compactMap { property in
            let domains = property.terms("Domain").compactMap { ontology.resolve($0).localName }
            guard domains.contains(className) else { return nil }
            return requirement(for: property)
        }
    }

    /// Every requirement an individual of all these classes stores: theirs
    /// and their local superclasses', each once, superclasses first.
    func storedRequirements(ofClasses classNames: [String]) -> [PropertyRequirement] {
        var order: [String] = []
        var visited: Set<String> = []
        func visit(_ name: String) {
            guard visited.insert(name).inserted, let declaration = ontology.declaration(named: name) else { return }
            for spelling in declaration.terms("SubClassOf") {
                if let local = ontology.resolve(spelling).localName, shapes[local] == .classProtocol { visit(local) }
            }
            order.append(name)
        }
        classNames.forEach(visit)

        var seen: Set<String> = []
        return order.flatMap(ownRequirements(of:)).filter { seen.insert($0.declaration.name).inserted }
    }

    // MARK: - Properties

    func requirement(for property: ParsedEntity) -> PropertyRequirement {
        PropertyRequirement(
            declaration: property,
            valueType: property.term("Range").map(valueType(ofRange:)) ?? "any RDFCore.Resource",
            isFunctional: isFunctional(property)
        )
    }

    /// The Swift type of one value of a range: the class protocol of a class,
    /// or the value type of a datatype or literal class.
    func valueType(ofRange spelling: String) -> String {
        let reference = ontology.resolve(spelling)
        if let name = reference.localName, shapes[name] == .classProtocol {
            return "any " + ontology.spelling(of: reference)
        }
        return ontology.spelling(of: reference)
    }

    /// Whether a property is typed `owl:FunctionalProperty`, or is a
    /// subproperty of a local functional property.
    func isFunctional(_ property: ParsedEntity, visited: Set<String> = []) -> Bool {
        if property.terms("Type").contains(where: { BootstrapTerm.isFunctionalProperty(ontology.canonical($0)) }) {
            return true
        }
        let visited = visited.union([property.name])
        return property.terms("SubPropertyOf").contains { spelling in
            guard let name = ontology.resolve(spelling).localName, !visited.contains(name),
                  let parent = ontology.declaration(named: name), parent.kind == .property else { return false }
            return isFunctional(parent, visited: visited)
        }
    }

    /// The local value type a functional property of a value type holds, if
    /// holding it would make that value type contain itself.
    func recursiveValueType(of typeName: String) -> (property: ParsedEntity, type: String)? {
        var visited: Set<String> = []
        var pending: [(name: String, first: ParsedEntity?)] = [(typeName, nil)]
        while let next = pending.popLast() {
            let (current, first) = next
            for requirement in ownRequirements(of: current) where requirement.isFunctional {
                guard let range = requirement.declaration.term("Range"),
                      let name = ontology.resolve(range).localName, shapes[name] == .value else { continue }
                let origin = first ?? requirement.declaration
                if name == typeName { return (origin, typeName) }
                if visited.insert(name).inserted { pending.append((name, origin)) }
            }
        }
        return nil
    }

    // MARK: - Shapes

    private func shape(computing declaration: ParsedEntity) -> Shape {
        if let form = BootstrapTerm.form(namespace: ontology.namespace, name: declaration.name) {
            return .alias(form: form.type, isGeneric: form.isGeneric)
        }
        switch declaration.kind {
        case .class: return isLiteralClass(declaration.name) ? .value : .classProtocol
        case .datatype: return .value
        case .property: return .propertyTerm
        case .individual: return .individual
        }
    }

    /// Whether a class is `rdfs:Literal` or one of its subclasses.
    private func isLiteralClass(_ name: String, visited: Set<String> = []) -> Bool {
        if BootstrapTerm.isLiteral("\(ontology.typeName).\(name)") { return true }
        guard let declaration = ontology.declaration(named: name) else { return false }
        let visited = visited.union([name])
        return declaration.terms("SubClassOf").contains { spelling in
            if BootstrapTerm.isLiteral(ontology.canonical(spelling)) { return true }
            guard let local = ontology.resolve(spelling).localName, !visited.contains(local),
                  ontology.declaration(named: local)?.kind == .class else { return false }
            return isLiteralClass(local, visited: visited)
        }
    }

    /// The spellings of the protocols a class's `SubClassOf` annotations name.
    private func superclassSpellings(of className: String) -> [String] {
        guard let declaration = ontology.declaration(named: className) else { return [] }
        return declaration.terms("SubClassOf").compactMap { spelling in
            let reference = ontology.resolve(spelling)
            if let local = reference.localName {
                switch shapes[local] {
                case .classProtocol: return ontology.spelling(of: reference)
                case .alias where BootstrapTerm.isResource(ontology.canonical(spelling)): return ontology.spelling(of: reference)
                default: return nil
                }
            }
            return spelling
        }
    }
}
