import IRIKit
import RDFCore

/// The object of a decoded triple.
///
/// RDF 1.2 Concepts §3.1 Triples: "The object, which is an IRI, a blank node,
/// a literal, or an RDF triple." A decoder produces this value as a document's
/// text enters the runtime; the IRIs it carries are boundary values.
public enum ObjectTerm: Object, Hashable, Sendable {
    /// An IRI object.
    case iri(IRI)

    /// A blank node object.
    case blankNode(BlankNode)

    /// A literal object.
    case literal(Literal)

    /// A triple term object.
    indirect case tripleTerm(TripleTermValue)
}

extension ObjectTerm {
    /// The same node in subject position, when it can be a subject.
    public var subject: SubjectTerm? {
        switch self {
        case .iri(let iri): .iri(iri)
        case .blankNode(let node): .blankNode(node)
        case .literal, .tripleTerm: nil
        }
    }
}
