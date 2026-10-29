import IRIKit
import RDFCore

/// The subject of a decoded triple.
///
/// RDF 1.2 Concepts §3.1 Triples: "The subject, which is an IRI or a blank
/// node". A decoder produces this value as a document's text enters the
/// runtime; the IRI it carries is a boundary value.
public enum SubjectTerm: Subject, Hashable, Sendable {
    /// An IRI subject.
    case iri(IRI)

    /// A blank node subject.
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
}
