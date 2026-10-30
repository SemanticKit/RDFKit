import RDFCore

/// The value of a property whose range admits any resource
/// (`rdfs:Resource`, or no range): an individual, a class or a literal
/// (RDF 1.2 Concepts §3.1: an object is an IRI, a blank node, a literal or a
/// triple term).
public enum Value: Sendable, Encodable {
    /// An individual.
    case individual(any Resource)
    /// A class: the Swift type of its members.
    case `class`(any Class.Type)
    /// A literal.
    case literal(Literal)

    /// Writes the value as its IRI or literal. An encoder that writes RDF
    /// reads the case instead.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .individual(let individual):
            guard let iri = individual.iri else {
                throw EncodingError.invalidValue(self, EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "A blank node has no IRI; an RDF encoder writes it as a blank node."
                ))
            }
            try container.encode(iri)
        case .class(let type):
            guard let iri = type.iri else {
                throw EncodingError.invalidValue(self, EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "A blank node has no IRI; an RDF encoder writes it as a blank node."
                ))
            }
            try container.encode(iri)
        case .literal(let literal):
            try container.encode(literal)
        }
    }
}
