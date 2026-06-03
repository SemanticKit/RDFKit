import Foundation

/// Attribute captured from RDF/XML source.
struct XMLAttribute {
    /// Attribute local name.
    let localName: String

    /// Attribute namespace prefix.
    let prefix: String?

    /// Attribute namespace IRI string.
    let namespaceURI: String?

    /// Attribute lexical value.
    let value: String
}
