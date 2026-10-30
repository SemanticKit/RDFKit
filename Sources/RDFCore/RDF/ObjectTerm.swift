import IRIKit

/// The object of a triple in a graph: any RDF term.
///
/// RDF 1.2 Concepts §3.1 Triples: "The object, which is an IRI, a blank node,
/// a literal, or an RDF triple." §3.2 RDF Terms: "IRIs, literals, blank
/// nodes, and triple terms are collectively known as RDF terms." The IRIs it
/// carries are boundary values: a decoder turns them into types on the way in.
public enum ObjectTerm: Object, Hashable, Sendable, CustomStringConvertible {
    /// An IRI.
    case iri(IRI)

    /// A blank node.
    case blankNode(BlankNode)

    /// A literal.
    case literal(Literal)

    /// A triple term: a triple used as an RDF term (RDF 1.2 Concepts §3.6).
    indirect case tripleTerm(Graph.Element)
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

    /// The term as N-Triples writes it, without escaping.
    public var description: String {
        switch self {
        case .iri(let iri): "<\(iri)>"
        case .blankNode(let node): node.description
        case .literal(let literal): literal.description
        case .tripleTerm(let triple): "<<( \(triple.subject) <\(triple.predicate)> \(triple.object) )>>"
        }
    }
}
