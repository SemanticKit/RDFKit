import Foundation

/// Errors produced while encoding or decoding RDF/XML RDF graphs.
public enum RDFXMLError: Error, CustomStringConvertible {
    /// The XML document is not a valid RDF/XML document.
    case invalidDocument(String)

    /// An XML element is not valid in its RDF/XML position.
    case invalidElement(String)

    /// An XML attribute is not valid in its RDF/XML position.
    case invalidAttribute(String)

    /// An IRI reference could not be resolved or represented.
    case invalidIri(String)

    /// A quoted triple term was malformed.
    case invalidTripleTerm(String)

    /// Human-readable error description.
    public var description: String {
        switch self {
        case let .invalidDocument(message):
            return "Invalid RDF/XML document: \(message)"
        case let .invalidElement(message):
            return "Invalid RDF/XML element: \(message)"
        case let .invalidAttribute(message):
            return "Invalid RDF/XML attribute: \(message)"
        case let .invalidIri(message):
            return "Invalid IRI: \(message)"
        case let .invalidTripleTerm(message):
            return "Invalid triple term: \(message)"
        }
    }
}
