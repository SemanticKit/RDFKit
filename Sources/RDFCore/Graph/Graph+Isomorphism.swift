import IRIKit

extension Graph {
    /// Whether this graph and `other` are isomorphic.
    ///
    /// RDF 1.2 Concepts §3.7 Graph Comparison: "Two RDF graphs G and G' are
    /// isomorphic (that is, they have an identical form) if there is a
    /// bijection M between the sets of nodes of the two graphs" that maps
    /// blank nodes to blank nodes, is the identity on IRIs and literals, and
    /// maps the triples of G onto those of G'. Two documents that decode to
    /// isomorphic graphs say the same thing.
    public func isIsomorphic(to other: Graph) -> Bool {
        GraphIsomorphism(left: self, right: other).holds()
    }
}

/// The search for a blank node bijection between two graphs.
///
/// Blank nodes are first coloured by the shape of the triples they occur in,
/// and the colours are refined from their neighbours' colours; the search
/// then only tries to map nodes of the same colour onto each other.
struct GraphIsomorphism {
    let left: Graph
    let right: Graph

    func holds() -> Bool {
        guard left.count == right.count else { return false }
        let leftNodes = Self.blankNodes(in: left)
        let rightNodes = Self.blankNodes(in: right)
        guard leftNodes.count == rightNodes.count else { return false }
        // Triples without blank nodes must be equal as they are.
        let leftGround = Graph(left.filter { Self.blankNodes(in: $0).isEmpty })
        let rightGround = Graph(right.filter { Self.blankNodes(in: $0).isEmpty })
        guard leftGround == rightGround else { return false }

        let leftColours = Self.colours(of: leftNodes, in: left)
        let rightColours = Self.colours(of: rightNodes, in: right)
        guard leftColours.values.sorted() == rightColours.values.sorted() else { return false }

        let ordered = leftNodes.sorted()
        var mapping: [BlankNode: BlankNode] = [:]
        var taken: Set<BlankNode> = []
        let leftTriples = left.subtracting(leftGround).map { ($0, Self.blankNodes(in: $0)) }
        return search(ordered[...], leftColours, rightColours, rightNodes.sorted(), leftTriples, &mapping, &taken)
    }

    func search(
        _ remaining: ArraySlice<BlankNode>,
        _ leftColours: [BlankNode: Int],
        _ rightColours: [BlankNode: Int],
        _ candidates: [BlankNode],
        _ leftTriples: [(Graph.Element, Set<BlankNode>)],
        _ mapping: inout [BlankNode: BlankNode],
        _ taken: inout Set<BlankNode>
    ) -> Bool {
        guard let node = remaining.first else { return true }
        for candidate in candidates where !taken.contains(candidate) && rightColours[candidate] == leftColours[node] {
            mapping[node] = candidate
            taken.insert(candidate)
            let consistent = leftTriples.allSatisfy { triple, nodes in
                !nodes.contains(node) || !nodes.isSubset(of: mapping.keys) || right.contains(Self.map(triple, mapping))
            }
            if consistent && search(remaining.dropFirst(), leftColours, rightColours, candidates, leftTriples, &mapping, &taken) {
                return true
            }
            mapping[node] = nil
            taken.remove(candidate)
        }
        return false
    }

    // MARK: - Colours

    static func colours(of nodes: Set<BlankNode>, in graph: Graph) -> [BlankNode: Int] {
        var colours = Dictionary(uniqueKeysWithValues: nodes.map { ($0, 0) })
        for _ in 0..<4 {
            var next: [BlankNode: [String]] = [:]
            for triple in graph {
                for node in blankNodes(in: triple) {
                    next[node, default: []].append(signature(triple, from: node, colours))
                }
            }
            colours = next.mapValues { $0.sorted().joined(separator: "|").hashValue }
        }
        return colours
    }

    /// The triple with every blank node replaced by its colour, and `node`
    /// itself marked.
    static func signature(_ triple: Graph.Element, from node: BlankNode, _ colours: [BlankNode: Int]) -> String {
        func name(_ blank: BlankNode) -> String { blank == node ? "*" : "_\(colours[blank] ?? 0)" }
        func subject(_ term: SubjectTerm) -> String {
            switch term {
            case .iri(let iri): "<\(iri)>"
            case .blankNode(let blank): name(blank)
            }
        }
        func object(_ term: ObjectTerm) -> String {
            switch term {
            case .iri(let iri): "<\(iri)>"
            case .blankNode(let blank): name(blank)
            case .literal(let literal): literal.description
            case .tripleTerm(let inner): "<<(\(subject(inner.subject)) <\(inner.predicate)> \(object(inner.object)))>>"
            }
        }
        return "\(subject(triple.subject)) <\(triple.predicate)> \(object(triple.object))"
    }

    // MARK: - Blank nodes

    static func blankNodes(in graph: Graph) -> Set<BlankNode> {
        graph.reduce(into: []) { $0.formUnion(blankNodes(in: $1)) }
    }

    static func blankNodes(in triple: Graph.Element) -> Set<BlankNode> {
        blankNodes(in: triple.subject).union(blankNodes(in: triple.object))
    }

    static func blankNodes(in term: SubjectTerm) -> Set<BlankNode> {
        if case .blankNode(let node) = term { return [node] }
        return []
    }

    static func blankNodes(in term: ObjectTerm) -> Set<BlankNode> {
        switch term {
        case .blankNode(let node): [node]
        case .tripleTerm(let inner): blankNodes(in: inner.subject).union(blankNodes(in: inner.object))
        case .iri, .literal: []
        }
    }

    // MARK: - Mapping

    static func map(_ triple: Graph.Element, _ mapping: [BlankNode: BlankNode]) -> Graph.Element {
        Graph.Element(subject: map(triple.subject, mapping), predicate: triple.predicate, object: map(triple.object, mapping))
    }

    static func map(_ term: SubjectTerm, _ mapping: [BlankNode: BlankNode]) -> SubjectTerm {
        if case .blankNode(let node) = term, let mapped = mapping[node] { return .blankNode(mapped) }
        return term
    }

    static func map(_ term: ObjectTerm, _ mapping: [BlankNode: BlankNode]) -> ObjectTerm {
        switch term {
        case .blankNode(let node): .blankNode(mapping[node] ?? node)
        case .tripleTerm(let inner):
            .tripleTerm(Graph.Element(subject: map(inner.subject, mapping), predicate: inner.predicate, object: map(inner.object, mapping)))
        case .iri, .literal: term
        }
    }
}
