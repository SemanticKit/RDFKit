import IRIKit
import RDFCore

/// Decides the Swift type of each property's values, what each class's
/// storing protocol gives its members, and the class of each individual one
/// module declares.
///
/// - A property's values are typed by its range: the value type of an XSD
///   datatype, literals for another literal class or datatype, classes for
///   a class of classes, the term types of properties for a class of
///   properties, the protocols of the range's classes for individuals, and
///   ``RDFCore/Value`` for a range that admits any resource. When the
///   documents give the property a value that type cannot hold, such as a
///   blank node as the value of `rdfs:comment`, its values are typed
///   `[RDFCore::Value]`. Every literal the documents give an XSD-typed
///   property leaves the type as it is: the individual holds the value it
///   denotes in the range, or, for one that denotes none (ill-typed, of a
///   datatype with no Swift type, or outside the range), keeps the literal
///   as a literal (``RDFCore/PropertyLiterals``).
/// - A class's storing protocol refines the storing protocols of the classes
///   it conforms to and of every property this module declares that a
///   member of it can have: one whose domain is the class or a superclass,
///   or that has no domain other than `rdfs:Resource` or `owl:Thing`. Every
///   resource is an `rdfs:Resource` (RDF 1.2 Semantics, rdfs4) and an
///   `owl:Thing` (OWL 2 RDF-Based Semantics, Table 5.2: `owl:Thing` "= IR"),
///   so every generated class conforms to their protocols where a module
///   declares them.
/// - An individual is an instance of the class of the one class its
///   documents state it is a member of, when that class conforms to every
///   class it is a member of and gives it every property it has. Otherwise
///   it is an instance of a class generated in this module for its stated
///   and entailed classes and its properties.
struct Planner {
    var declarations: Declarations
    let lower: Lower
    let vocabulary: Vocabulary
    let layer: Layer

    /// `rdfs:Resource` and `owl:Thing`, whose members are every resource.
    static let universal: Set<SubjectTerm> = [.iri(.rdfsResource), .iri(.owlThing)]

    private var conformances: [SubjectTerm: Set<SubjectTerm>] = [:]
    private var combinationKeys: [CombinationKey: Int] = [:]

    init(declarations: Declarations, lower: Lower, vocabulary: Vocabulary, layer: Layer) {
        self.declarations = declarations
        self.lower = lower
        self.vocabulary = vocabulary
        self.layer = layer
    }

    mutating func plan() throws {
        for node in declarations.order where declarations.individuals[node] != nil {
            conformances[node] = closure(protocols(of: node))
        }
        try planProperties()
        planRequirements()
        planClasses()
        for node in declarations.order where declarations.individuals[node] != nil {
            try planIndividual(node)
        }
    }

    // MARK: - Protocols

    /// The class declaration of `node`, here or below.
    func classDeclaration(_ node: SubjectTerm) -> ClassDeclaration? {
        declarations.classes[node] ?? lower.class(node)
    }

    /// The property declaration of `node`, here or below.
    func propertyDeclaration(_ node: SubjectTerm) -> PropertyDeclaration? {
        declarations.properties[node] ?? lower.property(node)
    }

    /// The protocols of `rdfs:Resource` and `owl:Thing`, where declared.
    private var universalProtocols: Set<SubjectTerm> {
        Set(Self.universal.filter { hasProtocol($0) })
    }

    /// Whether `node` is a class with a protocol, here or below: a class
    /// that is not an XSD datatype, whose Swift type is a value type.
    func hasProtocol(_ node: SubjectTerm) -> Bool {
        classDeclaration(node).map { !$0.isDatatype } ?? false
    }

    /// `nodes` and every protocol they refine.
    func closure(_ nodes: some Sequence<SubjectTerm>) -> Set<SubjectTerm> {
        var closure = Set(nodes)
        for node in nodes {
            closure.formUnion(lower.refinementClosure(of: node, local: declarations.refinements))
        }
        return closure
    }

    /// `nodes` without those another of them refines.
    func minimal(_ nodes: Set<SubjectTerm>) -> [SubjectTerm] {
        nodes.filter { node in
            !nodes.contains { other in other != node && closure([other]).contains(node) }
        }.sorted(by: SubjectTerm.inIRIOrder)
    }

    /// The protocols of the classes an individual is a member of, stated
    /// and entailed, and of the classes every resource is a member of.
    private func protocols(of node: SubjectTerm) -> Set<SubjectTerm> {
        Set((vocabulary.classes(of: node).union(stated(node))).filter(hasProtocol))
            .union(universalProtocols)
    }

    /// The classes the documents state `node` is a member of.
    func stated(_ node: SubjectTerm) -> [SubjectTerm] {
        var types: [SubjectTerm] = []
        for triple in layer.graph where triple.subject == node && triple.predicate == .rdfType {
            if let type = triple.object.node, !types.contains(type) { types.append(type) }
        }
        return types.sorted(by: SubjectTerm.inIRIOrder)
    }

    // MARK: - Properties

    /// The Swift type of a property's values, by its range.
    func kind(ofRanges ranges: [SubjectTerm]) -> ValueKind {
        if ranges.count == 1, vocabulary.datatypes.isDatatype(ranges[0]) { return .datatype(ranges[0]) }
        if ranges.contains(where: vocabulary.isLiteralClass) { return .literals }
        if ranges.contains(where: vocabulary.isMetaclass) { return .classes }
        if ranges.contains(where: vocabulary.isPropertyClass) { return .properties }
        if ranges.isEmpty || ranges.contains(.iri(.rdfsResource)) { return .values }
        let protocols = Set(ranges.filter { hasProtocol($0) && classDeclaration($0)?.isPublic == true })
        return .individuals(minimal(protocols))
    }

    /// Whether `kind` holds `value`.
    func holds(_ kind: ValueKind, _ value: ObjectTerm) -> Bool {
        switch (kind, value) {
        case (.values, _): return true
        case (.datatype, .literal): return true
        case (.datatype, _): return false
        case (.literals, .literal): return true
        case (_, .literal), (_, .tripleTerm): return false
        case (.literals, _): return false
        case (.classes, _): return value.node.flatMap(classDeclaration) != nil
        case (.properties, _): return value.node.flatMap(propertyDeclaration) != nil
        case (.individuals(let protocols), _):
            guard let node = value.node, classDeclaration(node) == nil, propertyDeclaration(node) == nil else { return false }
            let conformances = self.conformances[node] ?? lower.individual(node)?.conformances ?? []
            return Set(protocols).isSubset(of: conformances)
        }
    }

    /// Types each property this module declares by its range, or as any
    /// value when the documents of this module and those below give it a
    /// value its range's type cannot hold.
    private mutating func planProperties() throws {
        for node in declarations.order {
            guard var property = declarations.properties[node], let iri = node.iri else { continue }
            property.kind = kind(ofRanges: vocabulary.ranges(of: node))
            if !vocabulary.graph.allSatisfy({ $0.predicate != iri || holds(property.kind, $0.object) }) {
                property.kind = .values
            }
            declarations.properties[node] = property
        }
        // A property a module below declares keeps its type.
        for triple in layer.graph {
            guard declarations.properties[.iri(triple.predicate)] == nil,
                  let property = lower.property(.iri(triple.predicate)),
                  !holds(property.kind, triple.object) else { continue }
            throw TranslationError(description: "\(layer.module): a value of '\(triple.predicate)' on \(triple.subject) is not of the type \(property.module) gives the property's values")
        }
    }

    /// Whether a member of the classes `classes` can have `property`: its
    /// domain is one of them, or it has no domain other than the classes of
    /// every resource.
    private func applies(_ property: SubjectTerm, to classes: Set<SubjectTerm>) -> Bool {
        let domains = Set(vocabulary.domains(of: property)).subtracting(Self.universal)
        return domains.isEmpty || !domains.isDisjoint(with: classes)
    }

    /// A property is a requirement of the protocol of each of its domains
    /// that this module declares, when this module declares the property
    /// too and no protocol a member of the domain conforms to has a
    /// requirement of that name. Every class conforms to the protocols of
    /// `rdfs:Resource` and `owl:Thing`, so their requirements are planned
    /// first.
    private mutating func planRequirements() {
        for universal in [true, false] {
            for node in declarations.order {
                guard let property = declarations.properties[node], property.isPublic else { continue }
                for domain in vocabulary.domains(of: node) where Self.universal.contains(domain) == universal {
                    guard let protocolDeclaration = declarations.classes[domain], protocolDeclaration.isPublic else { continue }
                    let inherited = closure([domain]).union(closure(universalProtocols)).subtracting([domain])
                        .flatMap(requirements(of:)).compactMap(propertyDeclaration)
                    guard !inherited.contains(where: { $0.member == property.member }),
                          !(declarations.requirements[domain] ?? []).contains(node) else { continue }
                    declarations.requirements[domain, default: []].append(node)
                }
            }
        }
    }

    private func requirements(of node: SubjectTerm) -> [SubjectTerm] {
        declarations.requirements[node] ?? lower.requirements(of: node)
    }

    /// The properties a member of every class in `conformances` has an
    /// accessor for: those of their storing protocols.
    private func stored(conformingTo conformances: some Sequence<SubjectTerm>) -> Set<SubjectTerm> {
        var stored: Set<SubjectTerm> = []
        for node in closure(conformances) {
            stored.formUnion(classDeclaration(node)?.stored ?? [])
        }
        return stored
    }

    /// The properties this module declares that a member of a class
    /// conforming to `conformances` can have. A public storing protocol
    /// refines only public ones.
    private func ownProperties(conformingTo conformances: [SubjectTerm], isPublic: Bool) -> [SubjectTerm] {
        let classes = closure(conformances).union(Self.universal)
        return declarations.order.filter { node in
            guard let property = declarations.properties[node], property.isPublic || !isPublic else { return false }
            return applies(node, to: classes)
        }
    }

    private mutating func planClasses() {
        var own: [SubjectTerm: [SubjectTerm]] = [:]
        for node in declarations.order {
            guard var declaration = declarations.classes[node] else { continue }
            let superclasses = vocabulary.superclassClosure(of: node).filter(hasProtocol)
            declaration.conformances = minimal(Set(superclasses).union([node]).union(universalProtocols))
            declaration.member = kind(ofRanges: [node])
            own[node] = ownProperties(conformingTo: declaration.conformances, isPublic: declaration.isPublic)
            let inherited = minimal(closure(declaration.conformances).subtracting([node]).filter { other in
                classDeclaration(other)?.isPublic == true || !declaration.isPublic
            })
            declaration.storing = inherited.map(Storing.class) + own[node, default: []].map(Storing.property)
            declarations.classes[node] = declaration
        }
        // What a member of each class has an accessor for: the properties of
        // its own storing protocol and of those it refines.
        for node in declarations.order {
            guard var declaration = declarations.classes[node] else { continue }
            var stored = Set(own[node] ?? [])
            for other in closure(declaration.conformances) where other != node {
                if declarations.classes[other] != nil {
                    if declaration.storing.contains(.class(other)) || closure(declaration.storing.compactMap(\.class)).contains(other) {
                        stored.formUnion(own[other] ?? [])
                    }
                } else if let lowerClass = lower.class(other) {
                    stored.formUnion(lowerClass.stored)
                }
            }
            declaration.stored = stored
            declarations.classes[node] = declaration
        }
    }

    // MARK: - Individuals

    /// The values each property has on `node`, in document order.
    func values(of node: SubjectTerm) -> [(property: SubjectTerm, values: [ObjectTerm])] {
        var values: [(property: SubjectTerm, values: [ObjectTerm])] = []
        for triple in layer.graph where triple.subject == node && triple.predicate != .rdfType {
            let property = SubjectTerm.iri(triple.predicate)
            if let index = values.firstIndex(where: { $0.property == property }) {
                values[index].values.append(triple.object)
            } else {
                values.append((property, [triple.object]))
            }
        }
        return values
    }

    private mutating func planIndividual(_ node: SubjectTerm) throws {
        guard var declaration = declarations.individuals[node] else { return }
        let stated = self.stated(node)
        let required = protocols(of: node)
        let properties = values(of: node).map(\.property)
        declaration.conformances = closure(required)

        if stated.count == 1, let type = classDeclaration(stated[0]), !type.isDatatype, closure(type.conformances).isSuperset(of: required),
           properties.allSatisfy(type.stored.contains) {
            declaration.instanceOf = .class(stated[0])
            // A named individual's Swift class is its own, which carries its
            // declared key, so it is typed by its class's storing protocol,
            // which gives it every property a member of the class has.
            declaration.publicType = !type.isPublic ? existential(minimal(required))
                : node.iri == nil ? type.classReference : "any " + type.storingReference
            declarations.individuals[node] = declaration
            return
        }

        let conformances = minimal(required)
        let stored = self.stored(conformingTo: conformances)
        let extra = properties.filter { !stored.contains($0) }
        let key = CombinationKey(stated: stated, conformances: conformances, extra: extra)
        let index: Int
        if let existing = combinationKeys[key] {
            index = existing
        } else {
            index = declarations.combinations.count
            combinationKeys[key] = index
            declarations.combinations.append(Combination(
                name: combinationName(stated: stated, conformances: conformances),
                stated: stated,
                conformances: conformances,
                storing: conformances.map(Storing.class) + extra.map(Storing.property)
            ))
        }
        declaration.instanceOf = .combination(index)
        declaration.publicType = existential(conformances)
        declarations.individuals[node] = declaration
    }

    /// `any A & B` of the public protocols among `protocols`.
    func existential(_ protocols: [SubjectTerm]) -> String {
        let names = protocols.compactMap { classDeclaration($0) }.filter(\.isPublic).map(\.protocolReference)
        return "any " + (names.isEmpty ? "RDFCore::Resource" : names.joined(separator: " & "))
    }

    /// The name of a combination class: its stated classes, and the classes
    /// it is a member of beyond them.
    private func combinationName(stated: [SubjectTerm], conformances: [SubjectTerm]) -> String {
        func name(_ node: SubjectTerm) -> String {
            classDeclaration(node).map(\.protocolName) ?? node.iri.map(\.localName) ?? "blank node"
        }
        var text = stated.isEmpty ? "Untyped" : stated.map(name).joined(separator: " & ")
        let beyond = conformances.filter { !stated.contains($0) && !Self.universal.contains($0) }
        if !beyond.isEmpty { text += " in " + beyond.map(name).joined(separator: " & ") }
        var candidate = text + " Individual"
        var number = 2
        while declarations.combinations.contains(where: { $0.name == candidate }) {
            candidate = "\(text) Individual \(number)"
            number += 1
        }
        return candidate
    }
}

extension Storing {
    /// The class whose storing protocol this is.
    var `class`: SubjectTerm? {
        if case .class(let node) = self { return node }
        return nil
    }
}

private struct CombinationKey: Hashable {
    let stated: [SubjectTerm]
    let conformances: [SubjectTerm]
    let extra: [SubjectTerm]
}
