import IRIKit
import RDFCore
import RDFFormats

/// RDF graph isomorphism (RDF 1.2 Concepts §3.7): whether a bijection
/// between the blank nodes of two graphs maps one graph onto the other.
///
/// Blank nodes are first coloured by the shape of the triples they occur in,
/// and the colours are refined from their neighbours' colours; the search
/// then only tries to map nodes of the same colour onto each other.
struct GraphIsomorphism {
    let left: Set<DecodedTriple>
    let right: Set<DecodedTriple>

    init(_ left: [DecodedTriple], _ right: [DecodedTriple]) {
        self.left = Set(left)
        self.right = Set(right)
    }

    var holds: Bool {
        guard left.count == right.count else { return false }
        let leftNodes = Self.blankNodes(in: left)
        let rightNodes = Self.blankNodes(in: right)
        guard leftNodes.count == rightNodes.count else { return false }
        // Triples without blank nodes must be equal as they are.
        let leftGround = left.filter { Self.blankNodes(in: $0).isEmpty }
        let rightGround = right.filter { Self.blankNodes(in: $0).isEmpty }
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

    private func search(
        _ remaining: ArraySlice<BlankNode>,
        _ leftColours: [BlankNode: Int],
        _ rightColours: [BlankNode: Int],
        _ candidates: [BlankNode],
        _ leftTriples: [(DecodedTriple, Set<BlankNode>)],
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

    private static func colours(of nodes: Set<BlankNode>, in graph: Set<DecodedTriple>) -> [BlankNode: Int] {
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
    private static func signature(_ triple: DecodedTriple, from node: BlankNode, _ colours: [BlankNode: Int]) -> String {
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

    private static func blankNodes(in graph: Set<DecodedTriple>) -> Set<BlankNode> {
        graph.reduce(into: []) { $0.formUnion(blankNodes(in: $1)) }
    }

    private static func blankNodes(in triple: DecodedTriple) -> Set<BlankNode> {
        blankNodes(in: triple.subject).union(blankNodes(in: triple.object))
    }

    private static func blankNodes(in term: SubjectTerm) -> Set<BlankNode> {
        if case .blankNode(let node) = term { return [node] }
        return []
    }

    private static func blankNodes(in term: ObjectTerm) -> Set<BlankNode> {
        switch term {
        case .blankNode(let node): [node]
        case .tripleTerm(let inner): blankNodes(in: inner.subject).union(blankNodes(in: inner.object))
        case .iri, .literal: []
        }
    }

    // MARK: - Mapping

    private static func map(_ triple: DecodedTriple, _ mapping: [BlankNode: BlankNode]) -> DecodedTriple {
        DecodedTriple(subject: map(triple.subject, mapping), predicate: triple.predicate, object: map(triple.object, mapping))
    }

    private static func map(_ term: SubjectTerm, _ mapping: [BlankNode: BlankNode]) -> SubjectTerm {
        if case .blankNode(let node) = term, let mapped = mapping[node] { return .blankNode(mapped) }
        return term
    }

    private static func map(_ term: ObjectTerm, _ mapping: [BlankNode: BlankNode]) -> ObjectTerm {
        switch term {
        case .blankNode(let node): .blankNode(mapping[node] ?? node)
        case .tripleTerm(let inner):
            .tripleTerm(TripleTermValue(subject: map(inner.subject, mapping), predicate: inner.predicate, object: map(inner.object, mapping)))
        case .iri, .literal: term
        }
    }
}
