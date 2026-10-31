import IRIKit

/// The subject of a triple in a graph: an IRI or a blank node.
///
/// RDF 1.2 Concepts §3.1 Triples: "The subject, which is an IRI or a blank
/// node". The same two node kinds name the graphs of a ``Dataset``. The IRI
/// is a boundary value: a decoder turns it into a type on the way in.
public enum SubjectTerm: Subject, Hashable, Sendable, CustomStringConvertible {
    /// An IRI.
    case iri(IRI)

    /// A blank node.
    case blankNode(BlankNode)
}

extension SubjectTerm {
    /// The same node in object position.
    public var object: ObjectTerm {
        switch self {
        case .iri(let iri): .iri(iri)
        case .blankNode(let node): .blankNode(node)
        }
    }

    /// The node as N-Triples writes it, without escaping.
    public var description: String {
        switch self {
        case .iri(let iri): "<\(iri)>"
        case .blankNode(let node): node.description
        }
    }

    /// The blank node the term is, if it is one.
    public var blankNodes: [BlankNode] {
        if case .blankNode(let node) = self { return [node] }
        return []
    }

    /// The same term, a blank node replaced by the node `mapping` gives it.
    /// A blank node `mapping` does not name stays as it is.
    public func replacingBlankNodes(_ mapping: [BlankNode: BlankNode]) -> SubjectTerm {
        if case .blankNode(let node) = self, let mapped = mapping[node] { return .blankNode(mapped) }
        return self
    }
}
