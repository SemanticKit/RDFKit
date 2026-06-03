import Foundation

/// Element captured from RDF/XML source.
final class XMLElement {
    /// Element local name.
    let localName: String

    /// Element namespace prefix.
    let prefix: String?

    /// Element namespace IRI string.
    let namespaceURI: String?

    /// Element attributes.
    var attributes: [XMLAttribute]

    /// Element child content.
    var children: [XMLChild] = []

    /// Creates an RDF/XML element node.
    init(localName: String, prefix: String?, namespaceURI: String?, attributes: [XMLAttribute]) {
        self.localName = localName
        self.prefix = prefix
        self.namespaceURI = namespaceURI
        self.attributes = attributes
    }
}
