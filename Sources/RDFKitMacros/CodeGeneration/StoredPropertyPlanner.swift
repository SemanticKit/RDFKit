/// A stored property of a generated type, from a `Property` whose `Domain` is
/// that type or one of its superclasses in the same ontology.
struct StoredProperty {
    /// The property's local name, the stored property's name.
    let name: String
    /// The Swift type of the stored values: the range's generated type, or the
    /// Swift value type of a literal datatype.
    let valueType: String
    /// Whether the value is stored out of line, because storing it inline
    /// would make the generated struct recursive.
    let isIndirect: Bool
    /// The property declaration.
    let declaration: ParsedEntity
}

/// Decides which stored properties each generated type gets.
struct StoredPropertyPlanner {
    let ontology: ParsedOntology

    /// Local types that the macro generates as value structs.
    let valueTypes: Set<String>

    init(ontology: ParsedOntology) {
        self.ontology = ontology
        self.valueTypes = Set(
            ontology.declarations
                .filter { EntityGenerator.shape(of: $0, in: ontology) == .value }
                .map(\.name)
        )
    }

    /// The stored properties of a generated value type, in declaration order.
    func storedProperties(of typeName: String) -> [StoredProperty] {
        let edges = rangeEdges()
        let owners = [typeName] + superclasses(of: typeName)
        return ontology.properties.compactMap { property in
            guard let domain = property.term("Domain"),
                  case .local(let domainName) = ontology.resolve(domain),
                  owners.contains(domainName),
                  let range = property.term("Range") else { return nil }

            let reference = ontology.resolve(range)
            let spelling = ontology.spelling(of: reference)
            let canonical = reference.localName.map { "\(ontology.typeName).\($0)" } ?? spelling
            let valueType = BootstrapTerm.literalValueType(forRange: canonical) ?? spelling

            var isIndirect = false
            if BootstrapTerm.literalValueType(forRange: canonical) == nil,
               let rangeName = reference.localName, valueTypes.contains(rangeName) {
                isIndirect = reaches(from: rangeName, to: typeName, edges: edges)
            }
            return StoredProperty(name: property.name, valueType: valueType, isIndirect: isIndirect, declaration: property)
        }
    }

    /// Superclasses of a local type that are local value types, transitively.
    func superclasses(of typeName: String) -> [String] {
        var result: [String] = []
        var pending = [typeName]
        while let current = pending.popLast() {
            guard let declaration = ontology.declarations.first(where: { $0.name == current && $0.kind != .property }) else { continue }
            for spelling in declaration.terms("SubClassOf") {
                guard let name = ontology.resolve(spelling).localName,
                      valueTypes.contains(name), name != typeName, !result.contains(name) else { continue }
                result.append(name)
                pending.append(name)
            }
        }
        return result
    }

    /// For each local value type, the local value types its stored properties hold.
    private func rangeEdges() -> [String: Set<String>] {
        var edges: [String: Set<String>] = [:]
        for typeName in valueTypes {
            let owners = [typeName] + superclasses(of: typeName)
            for property in ontology.properties {
                guard let domain = property.term("Domain"),
                      let domainName = ontology.resolve(domain).localName,
                      owners.contains(domainName),
                      let range = property.term("Range"),
                      let rangeName = ontology.resolve(range).localName,
                      valueTypes.contains(rangeName),
                      BootstrapTerm.literalValueType(forRange: "\(ontology.typeName).\(rangeName)") == nil else { continue }
                edges[typeName, default: []].insert(rangeName)
            }
        }
        return edges
    }

    private func reaches(from start: String, to target: String, edges: [String: Set<String>]) -> Bool {
        var visited: Set<String> = []
        var pending = [start]
        while let current = pending.popLast() {
            if current == target { return true }
            guard visited.insert(current).inserted else { continue }
            pending.append(contentsOf: edges[current] ?? [])
        }
        return false
    }
}

extension TermReference {
    var localName: String? {
        if case .local(let name) = self { return name }
        return nil
    }

    var isLocal: Bool { localName != nil }
}
