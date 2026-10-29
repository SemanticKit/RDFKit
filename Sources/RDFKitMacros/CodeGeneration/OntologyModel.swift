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
///   The properties the DSL is written with (`rdfs:label` as `Label(...)`,
///   `rdfs:domain` as `Domain(...)`) are also annotation types.
struct OntologyModel {
    enum Shape: Equatable {
        /// A term RDFCore already provides.
        case alias(form: String, isGeneric: Bool)
        /// A property term the DSL is written with, such as `rdfs:label`.
        case annotation(BootstrapTerm.AnnotationForm)
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
        /// The Swift type of one value: the range's generated type, or the
        /// Swift value type of a literal range.
        let valueType: String
        /// Whether the property is an `owl:FunctionalProperty`: at most one value.
        let isFunctional: Bool

        /// The property name as a Swift identifier.
        var name: String { SwiftIdentifier.escaped(declaration.name) }

        /// Many values by default, at most one for a functional property.
        var declaredType: String {
            guard isFunctional else { return "[\(valueType)]" }
            return valueType.hasPrefix("any ") ? "(\(valueType))?" : "\(valueType)?"
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
    /// superclasses, or `RDFS.Resource` when it declares none. `rdfs:Resource`
    /// itself, the class of everything, is the root: an object with a
    /// boundary projection.
    func refinements(of className: String) -> [String] {
        isRoot(className) ? ["AnyObject", "RDFCore.Entity"] : superclassSpellings(of: className)
    }

    /// Whether a local class is `rdfs:Resource`.
    func isRoot(_ className: String) -> Bool {
        BootstrapTerm.isResource("\(ontology.typeName).\(className)")
    }

    /// Whether a class has individuals, so that the macro generates an
    /// individual type for it: `owl:Nothing` and its subclasses have none.
    func hasIndividuals(_ className: String) -> Bool {
        if BootstrapTerm.isNothing("\(ontology.typeName).\(className)") { return false }
        for ancestor in localAncestors(of: className) {
            if BootstrapTerm.isNothing("\(ontology.typeName).\(ancestor)") { return false }
        }
        return !directForeignSuperclasses(of: [className] + localAncestors(of: className))
            .contains { BootstrapTerm.isNothing($0.classSpelling) }
    }

    /// The storage names of a class this ontology declares.
    func storage(of className: String) -> ClassStorage {
        ClassStorage(ontology: ontology.typeName, name: className)
    }

    /// The storage names of a class written as a `Type(...)` or
    /// `SubClassOf(...)` argument, local or foreign; nil for a spelling that
    /// does not name its ontology.
    func storage(ofSpelling spelling: String) -> ClassStorage? {
        if let local = ontology.resolve(spelling).localName {
            return shapes[local] == .classProtocol ? storage(of: local) : nil
        }
        return ClassStorage(spelling: spelling)
    }

    /// The local classes a class refines, transitively, nearest first.
    func localAncestors(of className: String) -> [String] {
        var result: [String] = []
        var pending = localSuperclasses(of: className)
        while !pending.isEmpty {
            let next = pending.removeFirst()
            guard next != className, !result.contains(next) else { continue }
            result.append(next)
            pending.append(contentsOf: localSuperclasses(of: next))
        }
        return result
    }

    /// The classes whose values an individual of this class keeps in a slot
    /// of the class's values: every local ancestor, and every class of
    /// another ontology that the class or a local ancestor refines directly.
    /// The ancestors of those foreign classes are kept inside their values.
    func ancestorStorages(of className: String) -> [ClassStorage] {
        let locals = localAncestors(of: className)
        var result = locals.map(storage(of:))
        for foreign in directForeignSuperclasses(of: [className] + locals) where !result.contains(foreign) {
            result.append(foreign)
        }
        return result
    }

    /// Every class an individual of these classes belongs to and keeps
    /// values for: the classes themselves and their ancestor storages.
    func storages(ofClassSpellings spellings: [String]) -> [ClassStorage] {
        var result: [ClassStorage] = []
        for spelling in spellings {
            guard let own = storage(ofSpelling: spelling) else { continue }
            var all = [own]
            if let local = ontology.resolve(spelling).localName { all += ancestorStorages(of: local) }
            for storage in all where !result.contains(storage) { result.append(storage) }
        }
        return result
    }

    /// The properties a class's values store: its own, and any property that
    /// two or more of its local classes require (a property with several
    /// domains), so that the class settles which one value it has.
    func storedOwnRequirements(of className: String) -> [PropertyRequirement] {
        var result = ownRequirements(of: className)
        for requirement in sharedRequirements(among: [className] + localAncestors(of: className))
        where !result.contains(where: { $0.declaration.name == requirement.declaration.name }) {
            result.append(requirement)
        }
        return result
    }

    /// The properties that two or more of these local classes store.
    func sharedRequirements(among classNames: [String]) -> [PropertyRequirement] {
        var counts: [String: Int] = [:]
        var order: [PropertyRequirement] = []
        for name in classNames {
            for requirement in ownRequirements(of: name) {
                if counts[requirement.declaration.name] == nil { order.append(requirement) }
                counts[requirement.declaration.name, default: 0] += 1
            }
        }
        return order.filter { counts[$0.declaration.name, default: 0] > 1 }
    }

    /// Where an individual of `className` keeps a requirement's value: in the
    /// class's own values (nil), or in the slot of the nearest local ancestor
    /// that stores it.
    func slot(of requirement: PropertyRequirement, inValuesOf className: String) -> String? {
        let name = requirement.declaration.name
        if storedOwnRequirements(of: className).contains(where: { $0.declaration.name == name }) { return nil }
        for ancestor in localAncestors(of: className)
        where storedOwnRequirements(of: ancestor).contains(where: { $0.declaration.name == name }) {
            return storage(of: ancestor).slot
        }
        return nil
    }

    private func localSuperclasses(of className: String) -> [String] {
        superclassSpellings(of: className).compactMap { ontology.resolve($0).localName }
    }

    /// The classes of other ontologies that these local classes refine directly.
    private func directForeignSuperclasses(of classNames: [String]) -> [ClassStorage] {
        var result: [ClassStorage] = []
        for name in classNames {
            for spelling in superclassSpellings(of: name) {
                guard ontology.resolve(spelling).localName == nil,
                      let foreign = storage(ofSpelling: spelling),
                      !result.contains(foreign) else { continue }
                result.append(foreign)
            }
        }
        return result
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
            valueType: property.term("Range").map(valueType(ofRange:)) ?? "any \(BootstrapTerm.resource)",
            isFunctional: isFunctional(property)
        )
    }

    /// The Swift type of one value of a range.
    func valueType(ofRange spelling: String) -> String {
        if let literal = BootstrapTerm.literalValueType(forRange: ontology.canonical(spelling)) {
            return literal
        }
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
        let spelling = "\(ontology.typeName).\(declaration.name)"
        if let form = BootstrapTerm.form(of: spelling) {
            return .alias(form: form.type, isGeneric: form.isGeneric)
        }
        if declaration.kind == .property, let form = BootstrapTerm.annotationForm(of: spelling) {
            return .annotation(form)
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

    /// The qualified spellings of the class protocols a class refines: the
    /// classes its `SubClassOf` annotations name, or `RDFS.Resource`, the
    /// class of everything, when they name none. `rdfs:Resource` refines none.
    private func superclassSpellings(of className: String) -> [String] {
        if isRoot(className) { return [] }
        var result: [String] = []
        for spelling in ontology.declaration(named: className)?.terms("SubClassOf") ?? [] {
            let reference = ontology.resolve(spelling)
            if let local = reference.localName, shapes[local] != .classProtocol { continue }
            let qualified = ontology.spelling(of: reference)
            if !result.contains(qualified) { result.append(qualified) }
        }
        return result.isEmpty ? [BootstrapTerm.resource] : result
    }
}
