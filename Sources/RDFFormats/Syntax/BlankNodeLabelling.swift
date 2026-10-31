import IRIKit
import RDFCore

/// The label each blank node of one document an encoder writes is written
/// under.
///
/// A blank node is written with its identifier when that identifier is a
/// `BLANK_NODE_LABEL`. RDF 1.2 Concepts §3.5 leaves the set of blank nodes
/// arbitrary, so an identifier can be one the grammars do not allow, such as
/// `nodeID://b1`; such a node is written under a fresh label, `b0`, `b1` and
/// so on, that no other node in the document uses, the same label every time
/// it occurs.
struct BlankNodeLabelling {
    /// The identifiers that are labels already, which fresh labels avoid.
    private let inUse: Set<String>
    private var fresh: [BlankNode: String] = [:]
    private var next = 0

    init(_ graph: Graph) {
        self.inUse = Set(graph.flatMap(\.blankNodes).map(\.identifier).filter(Self.isLabel))
    }

    /// The label of `node`, without `_:`.
    mutating func label(for node: BlankNode) -> String {
        if Self.isLabel(node.identifier) { return node.identifier }
        if let label = fresh[node] { return label }
        var label: String
        repeat {
            label = "b\(next)"
            next += 1
        } while inUse.contains(label)
        fresh[node] = label
        return label
    }

    /// The subject as N-Triples writes it.
    mutating func nTriples(_ subject: SubjectTerm) -> String {
        switch subject {
        case .iri(let iri): iri.iriReference
        case .blankNode(let node): "_:" + label(for: node)
        }
    }

    /// The object as N-Triples writes it.
    mutating func nTriples(_ object: ObjectTerm) -> String {
        switch object {
        case .iri(let iri): iri.iriReference
        case .blankNode(let node): "_:" + label(for: node)
        case .literal(let literal): literal.nTriples
        case .tripleTerm(let term): "<<( " + nTriples(term) + " )>>"
        }
    }

    /// The triple's three terms as N-Triples writes them, without the `.`.
    mutating func nTriples(_ triple: Graph.Element) -> String {
        nTriples(triple.subject) + " " + triple.predicate.iriReference + " " + nTriples(triple.object)
    }

    /// Whether `_:` and the identifier are a `BLANK_NODE_LABEL` (RDF 1.2
    /// N-Triples §5.3, Turtle §6.5).
    static func isLabel(_ identifier: String) -> Bool {
        NTriplesGrammar.BLANK_NODE_LABEL.matches("_:" + identifier)
    }
}
