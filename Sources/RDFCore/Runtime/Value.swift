/// The value of a property whose range admits any resource
/// (`rdfs:Resource`, or no range): an individual, a class, a property, a
/// literal or a triple term (RDF 1.2 Concepts §3.1: an object is an IRI, a
/// blank node, a literal or a triple term).
public enum Value: Sendable, Encodable {
    /// An individual.
    case individual(any Resource)
    /// A class: the Swift type of its members.
    case `class`(any ResourceClass.Type)
    /// A property: its term type.
    case property(any PropertyTerm.Type)
    /// A literal.
    case literal(Literal)
    /// A triple term (RDF 1.2 Concepts §3.6: "A triple term is an RDF triple
    /// used as an RDF term within another triple"): its subject and object
    /// as Swift values, and its predicate as the property's term type.
    indirect case tripleTerm(subject: Value, predicate: any PropertyTerm.Type, object: Value)

    /// Writes the value as the IRI its declared key gives, or as its literal. An
    /// encoder that writes RDF reads the case instead, and writes an
    /// individual or class without an IRI as a blank node, and a triple term
    /// as a triple term.
    ///
    /// - Throws: `EncodingError.invalidValue` for an individual or class
    ///   that is a blank node, which has no IRI to write, and for a triple
    ///   term, which is not one IRI.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let key: TermKey?
        switch self {
        case .individual(let individual): key = type(of: individual).key
        case .class(let type): key = type.classKey
        case .property(let term): key = term.key
        case .literal(let literal): return try container.encode(literal)
        case .tripleTerm:
            throw EncodingError.invalidValue(self, EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "A triple term is not an IRI; an RDF encoder writes it as a triple term."
            ))
        }
        guard let key else {
            throw EncodingError.invalidValue(self, EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "A blank node has no IRI; an RDF encoder writes it as a blank node."
            ))
        }
        try container.encode(key.stringValue)
    }
}
