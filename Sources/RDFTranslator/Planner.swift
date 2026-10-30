/// Decides the stored properties of each generated class and the class of
/// each individual one module declares.
///
/// - A class's members are the requirements of the protocols it conforms to
///   and every property a member of it can have: one whose domain is the
///   class or a superclass, or that has no domain other than `rdfs:Resource`
///   or `owl:Thing`. Every resource is an `rdfs:Resource` (RDF 1.2
///   Semantics, rdfs4) and an `owl:Thing` (OWL 2 RDF-Based Semantics,
///   Table 5.2: `owl:Thing` "= IR"), so every generated class conforms to
///   their protocols where a module declares them.
/// - A member is typed by its property's range: literals for a literal
///   class or datatype, classes for a class of classes, the protocols of
///   the range's classes for individuals, and ``RDFRuntime/Value`` for a
///   range that admits any resource. When the documents give a member a
///   value its range type cannot hold, such as a blank node as the value of
///   `rdfs:comment`, the member is typed `[RDFRuntime.Value]`.
/// - An individual is an instance of the class of the one class its
///   documents state it is a member of, when that class conforms to every
///   class it is a member of and stores every property it has. Otherwise it
///   is an instance of a class generated in this module for its stated and
///   entailed classes.
struct Planner {
    var declarations: Declarations
    let lower: Lower
    let vocabulary: Vocabulary
    let layer: Layer

    /// `rdfs:Resource` and `owl:Thing`, whose members are every resource.
    static let universal: Set<NodeID> = [.iri(Term.resource), .iri(Term.thing)]

    private var conformances: [NodeID: Set<NodeID>] = [:]
    private var combinationKeys: [CombinationKey: Int] = [:]

    init(declarations: Declarations, lower: Lower, vocabulary: Vocabulary, layer: Layer) {
        self.declarations = declarations
        self.lower = lower
        self.vocabulary = vocabulary
        self.layer = layer
    }

    mutating func plan() throws {
        planRequirements()
        try planClasses()
        for node in declarations.order where declarations.individuals[node] != nil {
            conformances[node] = closure(protocols(of: node))
        }
        for node in declarations.order where declarations.individuals[node] != nil {
            try planIndividual(node)
        }
    }

    // MARK: - Protocols

    /// The class declaration of `node`, here or below.
    func classDeclaration(_ node: NodeID) -> ClassDeclaration? {
        declarations.classes[node] ?? lower.class(node)
    }

    /// The protocols of `rdfs:Resource` and `owl:Thing`, where declared.
    private var universalProtocols: Set<NodeID> {
        Set(Self.universal.filter { classDeclaration($0) != nil })
    }

    /// `nodes` and every protocol they refine.
    func closure(_ nodes: some Sequence<NodeID>) -> Set<NodeID> {
        var closure = Set(nodes)
        for node in nodes {
            closure.formUnion(lower.refinementClosure(of: node, local: declarations.refinements))
        }
        return closure
    }

    /// `nodes` without those another of them refines.
    func minimal(_ nodes: Set<NodeID>) -> [NodeID] {
        nodes.filter { node in
            !nodes.contains { other in other != node && closure([other]).contains(node) }
        }.sorted { ($0.iri ?? "") < ($1.iri ?? "") }
    }

    /// The protocols of the classes an individual is a member of, stated
    /// and entailed, and of the classes every resource is a member of.
    private func protocols(of node: NodeID) -> Set<NodeID> {
        Set((vocabulary.classes(of: node).union(stated(node))).filter { classDeclaration($0) != nil })
            .union(universalProtocols)
    }

    /// The classes the documents state `node` is a member of.
    func stated(_ node: NodeID) -> [NodeID] {
        var types: [NodeID] = []
        for statement in layer.statements where statement.subject == node && statement.predicate == Term.type {
            if let type = statement.object.node, !types.contains(type) { types.append(type) }
        }
        return types.sorted { ($0.iri ?? "") < ($1.iri ?? "") }
    }

    // MARK: - Members

    /// The Swift type of a property's values, by its range.
    func kind(of property: NodeID) -> ValueKind {
        let ranges = vocabulary.ranges(of: property)
        if ranges.contains(where: vocabulary.isLiteralClass) { return .literals }
        if ranges.contains(where: vocabulary.isMetaclass) { return .classes }
        if ranges.isEmpty || ranges.contains(.iri(Term.resource)) { return .values }
        let protocols = Set(ranges.filter { classDeclaration($0)?.isPublic == true })
        return .individuals(minimal(protocols))
    }

    /// The name a property's member takes when nothing else in its class has
    /// it.
    func memberName(of property: NodeID) -> String {
        if let declaration = declarations.individuals[property] ?? lower.individual(property) {
            if declaration.isPublic { return declaration.name }
            if let iri = property.iri, case let name = SwiftName.localName(of: iri), SwiftName.isUsable(name) { return name }
            return declaration.name
        }
        return SwiftName.localName(of: property.iri ?? "")
    }

    /// Whether a member of the classes `classes` can have `property`: its
    /// domain is one of them, or it has no domain other than the classes of
    /// every resource.
    private func applies(_ property: NodeID, to classes: Set<NodeID>) -> Bool {
        let domains = Set(vocabulary.domains(of: property)).subtracting(Self.universal)
        return domains.isEmpty || !domains.isDisjoint(with: classes)
    }

    /// A property is a requirement of the protocol of each of its domains
    /// that this module declares, when this module declares the property
    /// too and no protocol a member of the domain conforms to has a
    /// requirement of that name. Every class conforms to the protocols of
    /// `rdfs:Resource` and `owl:Thing`, so their requirements are planned
    /// first, and a property of another domain with the name of one of them
    /// is stored under another name.
    private mutating func planRequirements() {
        for universal in [true, false] {
            for property in declarations.properties {
                guard let declaration = declarations.individuals[property], declaration.isPublic,
                      !Declarations.memberNames.contains(declaration.name) else { continue }
                for domain in vocabulary.domains(of: property) where Self.universal.contains(domain) == universal {
                    guard let protocolDeclaration = declarations.classes[domain], protocolDeclaration.isPublic else { continue }
                    let inherited = closure([domain]).union(closure(universalProtocols)).subtracting([domain]).flatMap(requirements(of:))
                    guard !inherited.contains(where: { $0.name == declaration.name }),
                          !(declarations.requirements[domain] ?? []).contains(where: { $0.property == property }) else { continue }
                    declarations.requirements[domain, default: []].append(
                        Member(property: property, name: declaration.name, kind: kind(of: property), isRequirement: true)
                    )
                }
            }
        }
    }

    private func requirements(of node: NodeID) -> [Member] {
        declarations.requirements[node] ?? lower.requirements(of: node)
    }

    /// The members of a class that conforms to `conformances`: the
    /// requirements of every protocol it conforms to, then every property
    /// a member of it can have, each named by its property unless an
    /// earlier member has that name.
    private func members(conformingTo conformances: [NodeID]) throws -> [Member] {
        let protocols = closure(conformances)
        var members: [Member] = []
        var names: Set<String> = Declarations.memberNames
        for node in protocols.sorted(by: { ($0.iri ?? "") < ($1.iri ?? "") }) {
            for requirement in requirements(of: node) where !members.contains(where: { $0.property == requirement.property }) {
                guard names.insert(requirement.name).inserted else {
                    throw TranslationError(description: "\(layer.module): two requirements named '\(requirement.name)' meet in one class")
                }
                members.append(requirement)
            }
        }
        let classes = protocols.union(Self.universal)
        for property in declarations.properties where applies(property, to: classes) {
            add(property, to: &members, names: &names)
        }
        return members
    }

    private func add(_ property: NodeID, to members: inout [Member], names: inout Set<String>) {
        guard !members.contains(where: { $0.property == property }) else { return }
        let base = memberName(of: property)
        var name = base
        var number = 2
        while !names.insert(name).inserted {
            name = "\(base) \(number)"
            number += 1
        }
        members.append(Member(property: property, name: name, kind: kind(of: property)))
    }

    private mutating func planClasses() throws {
        for node in declarations.order {
            guard var declaration = declarations.classes[node] else { continue }
            let superclasses = vocabulary.superclassClosure(of: node).filter { classDeclaration($0) != nil }
            declaration.conformances = minimal(Set(superclasses).union([node]).union(universalProtocols))
            declaration.members = try members(conformingTo: declaration.conformances)
            declarations.classes[node] = declaration
        }
    }

    // MARK: - Individuals

    /// The values each property has on `node`, in document order.
    private func values(of node: NodeID) -> [(property: NodeID, values: [ObjectValue])] {
        var values: [(property: NodeID, values: [ObjectValue])] = []
        for statement in layer.statements where statement.subject == node && statement.predicate != Term.type {
            let property = NodeID.iri(statement.predicate)
            if let index = values.firstIndex(where: { $0.property == property }) {
                values[index].values.append(statement.object)
            } else {
                values.append((property, [statement.object]))
            }
        }
        return values
    }

    /// Whether `kind` holds `value`.
    func holds(_ kind: ValueKind, _ value: ObjectValue) -> Bool {
        switch (kind, value) {
        case (.values, _): return true
        case (.literals, .literal): return true
        case (_, .literal): return false
        case (.literals, .node): return false
        case (.classes, .node(let node)): return classDeclaration(node) != nil
        case (.individuals(let protocols), .node(let node)):
            guard classDeclaration(node) == nil else { return false }
            let conformances = self.conformances[node] ?? lower.individual(node)?.conformances ?? []
            return Set(protocols).isSubset(of: conformances)
        }
    }

    private mutating func planIndividual(_ node: NodeID) throws {
        guard var declaration = declarations.individuals[node] else { return }
        let stated = self.stated(node)
        let required = protocols(of: node)
        let values = self.values(of: node)
        declaration.conformances = closure(required)

        if stated.count == 1, let type = classDeclaration(stated[0]), closure(type.conformances).isSuperset(of: required),
           var members = Optional(type.members),
           values.allSatisfy({ property, _ in members.contains { $0.property == property } }) {
            let local = declarations.classes[stated[0]] != nil
            var fits = true
            for (property, objects) in values {
                let index = members.firstIndex { $0.property == property }!
                guard !objects.allSatisfy({ holds(members[index].kind, $0) }) else { continue }
                if local && !members[index].isRequirement {
                    members[index].kind = .values
                } else {
                    fits = false
                }
            }
            if fits {
                if local { declarations.classes[stated[0]]!.members = members }
                declaration.instanceOf = .class(stated[0])
                declaration.publicType = type.isPublic ? type.classReference : existential(minimal(required))
                declarations.individuals[node] = declaration
                return
            }
        }

        let conformances = minimal(required)
        let key = CombinationKey(stated: stated, conformances: conformances)
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
                members: try members(conformingTo: conformances)
            ))
        }
        var members = declarations.combinations[index].members
        var names = Set(members.map(\.name)).union(Declarations.memberNames)
        for (property, objects) in values {
            if !members.contains(where: { $0.property == property }) {
                add(property, to: &members, names: &names)
            }
            let position = members.firstIndex { $0.property == property }!
            guard !objects.allSatisfy({ holds(members[position].kind, $0) }) else { continue }
            guard !members[position].isRequirement else {
                throw TranslationError(description: "\(layer.module): a value of '\(property.iri ?? "")' on \(node.iri ?? "a blank node") is not of the type its protocol requires")
            }
            members[position].kind = .values
        }
        declarations.combinations[index].members = members
        declaration.instanceOf = .combination(index)
        declaration.publicType = existential(conformances)
        declarations.individuals[node] = declaration
    }

    /// `any A & B` of the public protocols among `protocols`.
    func existential(_ protocols: [NodeID]) -> String {
        let names = protocols.compactMap { classDeclaration($0) }.filter(\.isPublic).map(\.protocolReference)
        return "any " + (names.isEmpty ? "RDFRuntime.Resource" : names.joined(separator: " & "))
    }

    /// The name of a combination class: its stated classes, and the classes
    /// it is a member of beyond them.
    private func combinationName(stated: [NodeID], conformances: [NodeID]) -> String {
        func name(_ node: NodeID) -> String {
            classDeclaration(node).map(\.protocolName) ?? SwiftName.localName(of: node.iri ?? "")
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

private struct CombinationKey: Hashable {
    let stated: [NodeID]
    let conformances: [NodeID]
}
