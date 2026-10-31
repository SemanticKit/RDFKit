/// The value of a property whose range admits any resource (`rdfs:Resource`,
/// or no range), as a Swift thing (RDF 1.2 Concepts §3.1: an object is an
/// IRI, a blank node, a literal or a triple term).
///
/// A node is the Swift object that is the resource, or the Swift type of a
/// class or property; a literal is its Swift value. No IRI and no
/// ``Literal`` appear here: the encoder derives both at the boundary.
public enum Value: Sendable, Encodable {
    /// An individual.
    case individual(any Resource)
    /// A class: the Swift type of its members.
    case `class`(any ResourceClass.Type)
    /// A property: its term type.
    case property(any PropertyTerm.Type)
    /// A string, a simple literal (RDF 1.2 Concepts §3.4).
    case string(String)
    /// A value of a datatype, as its Swift value type.
    case datatype(any DatatypeValue)
    /// A triple term (RDF 1.2 Concepts §3.6: "A triple term is an RDF triple
    /// used as an RDF term within another triple"): its subject and object
    /// as values, and its predicate as the property's term type.
    indirect case tripleTerm(subject: Value, predicate: any PropertyTerm.Type, object: Value)

    /// An RDF encoder reads the case. Any other encoder gets the string or
    /// the datatype value's lexical form; nodes and triple terms have no
    /// representation outside RDF.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string): try container.encode(string)
        case .datatype(let value): try container.encode(value.lexicalForm)
        case .individual, .class, .property, .tripleTerm:
            throw EncodingError.invalidValue(self, EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "A node or triple term is written only by an RDF encoder."
            ))
        }
    }
}
