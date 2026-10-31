import IRIKit
import RDFCore

/// Encodes a graph as canonical RDF 1.2 N-Triples (§4).
///
/// Each triple is written on its own line, with single
/// spaces between terms, no comments and a line feed after the final `.`.
/// Literals escape `"`, `\`, the control characters and U+FFFE and U+FFFF;
/// `xsd:string` is never written; language tags are lower case. IRIs are the
/// boundary values the triples carry, written as they are. Triples are
/// written in the graph's order, the order they were first inserted.
///
/// A blank node is written with its identifier when that identifier is a
/// `BLANK_NODE_LABEL`. RDF 1.2 Concepts §3.5 leaves the set of blank nodes
/// arbitrary, so an identifier can be one the N-Triples grammar does not
/// allow, such as `nodeID://b1`; such a node is written under a fresh
/// label, `b0`, `b1` and so on, that no other node in the document uses, the
/// same label every time it occurs.
public struct NTriplesEncoder: Sendable {
    /// Creates an N-Triples encoder.
    public init() {}

    /// Encodes a graph as a canonical N-Triples document.
    public func encode(_ graph: Graph) -> String {
        var labels = BlankNodeLabelling(graph)
        return graph.map { triple in labels.nTriples(triple) + " .\n" }.joined()
    }
}
