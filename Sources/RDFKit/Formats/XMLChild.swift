import Foundation

/// Child content in the RDF/XML decoder tree.
enum XMLChild {
    /// A nested XML element.
    case element(XMLElement)

    /// Text content.
    case text(String)
}
