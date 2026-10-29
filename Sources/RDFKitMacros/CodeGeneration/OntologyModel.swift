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
    /// superclasses, or ``RDFCore/Resource`` when it declares none.
    func refinements(of className: String) -> [String] {
        var result: [String] = []
        for spelling in superclassSpellings(of: className) where !result.contains(spelling) {
            result.append(spelling)
        }
        return result.isEmpty ? ["RDFCore.Resource"] : result
    }

    /// Whether a class has individuals: every class does except `owl:Nothing`
    /// and its subclasses.
    ///
    /// A class may refine another ontology's classes. Its individual type
    /// still conforms to them, because every property requirement has a
    /// default implementation that keeps the values in the individual's
    /// ``RDFCore/IndividualStorage``.
    func hasIndividuals(_ className: String) -> Bool {
        var visited: Set<String> = []
        var pending = [className]
        while let current = pending.popLast() {
            guard visited.insert(current).inserted, let declaration = ontology.declaration(named: current) else { continue }
            if BootstrapTerm.isNothing("\(ontology.typeName).\(current)") { return false }
            for spelling in declaration.terms("SubClassOf") {
                if BootstrapTerm.isNothing(ontology.canonical(spelling)) { return false }
                if let name = ontology.resolve(spelling).localName { pending.append(name) }
            }
        }
        return true
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
            valueType: valueType(ofRanges: property.terms("Range")),
            isFunctional: isFunctional(property)
        )
    }

    /// The Swift type of one value of a property with these ranges.
    ///
    /// Several `Range`s mean a value is in all of them: class ranges become a
    /// protocol composition, `any Cert.Key & Cert.PublicKey`, and literal
    /// ranges that store the same Swift value type are that type. A property
    /// without a `Range` holds any resource.
    func valueType(ofRanges spellings: [String]) -> String {
        var types: [String] = []
        for type in spellings.map(valueType(ofRange:)) where !types.contains(type) {
            types.append(type)
        }
        guard types.count > 1 else { return types.first ?? Self.anyResource }
        let resources = types.filter { $0 != Self.anyResource }
        guard resources.count > 1 else { return resources.first ?? Self.anyResource }
        return "any " + resources.map { $0.hasPrefix("any ") ? String($0.dropFirst(4)) : $0 }.joined(separator: " & ")
    }

    /// The Swift type of one value of a range.
    func valueType(ofRange spelling: String) -> String {
        let canonical = ontology.canonical(spelling)
        if let literal = BootstrapTerm.literalValueType(forRange: canonical) {
            return literal
        }
        let reference = ontology.resolve(spelling)
        // Another ontology's classes do not refine `owl:Thing`, but every
        // individual is one, so there `owl:Thing` is any resource.
        if BootstrapTerm.isResource(canonical) || (BootstrapTerm.isThing(canonical) && reference.localName == nil) {
            return Self.anyResource
        }
        if let name = reference.localName, shapes[name] == .classProtocol {
            return "any " + ontology.spelling(of: reference)
        }
        return ontology.spelling(of: reference)
    }

    /// The subject types a property applies to, one for each `Domain`: the
    /// classes' protocols, or any resource for a property without a domain
    /// or with the domain `rdfs:Resource` or `owl:Thing`. Value types and
    /// literals have no property storage, so they are left out.
    func subjectTypes(of property: ParsedEntity) -> [String] {
        let domains = property.terms("Domain")
        guard !domains.isEmpty else { return [Self.anyResource] }
        var result: [String] = []
        for domain in domains {
            let canonical = ontology.canonical(domain)
            var type = valueType(ofRange: domain)
            if type != Self.anyResource {
                if let name = ontology.resolve(domain).localName, shapes[name] != .classProtocol { continue }
                if BootstrapTerm.literalValueType(forRange: canonical) != nil || BootstrapTerm.isLiteral(canonical) { continue }
                if !type.hasPrefix("any ") { type = "any " + type }
            }
            if !result.contains(type) { result.append(type) }
        }
        return result
    }

    /// The `Domain` type alias of a property: what a subject of the property
    /// is, in every one of its domains.
    func domainType(of property: ParsedEntity) -> String {
        let subjects = subjectTypes(of: property)
        let domains = property.terms("Domain")
        guard subjects.count == domains.count, !subjects.isEmpty else {
            return domains.first.map(valueType(ofRange:)) ?? Self.anyResource
        }
        let classes = subjects.filter { $0 != Self.anyResource }
        guard classes.count > 1 else { return classes.first ?? Self.anyResource }
        return "any " + classes.map { String($0.dropFirst(4)) }.joined(separator: " & ")
    }

    /// Whether a property is a requirement of a class protocol this ontology
    /// declares.
    func isRequirement(_ property: ParsedEntity) -> Bool {
        property.terms("Domain").contains { spelling in
            guard let name = ontology.resolve(spelling).localName else { return false }
            return shapes[name] == .classProtocol
        }
    }

    static let anyResource = "any RDFCore.Resource"

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
                guard requirement.declaration.terms("Range").count == 1,
                      let range = requirement.declaration.term("Range"),
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
