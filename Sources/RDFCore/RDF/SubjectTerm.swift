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
}
