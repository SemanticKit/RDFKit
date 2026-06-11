import Foundation

/// Errors thrown while constructing or storing RDF terms.
public enum RDFTermError: Error, LocalizedError {
    /// A blank node identifier was empty.
    case emptyBlankNodeIdentifier

    /// A language tag was empty.
    case emptyLanguageTag

    /// A language-tagged literal also declared a datatype.
    case languageTagWithDatatype

    /// A text direction was supplied without a language tag.
    case textDirectionRequiresLanguageTag

    /// A subject was not an IRI or blank node.
    case invalidSubject

    public var errorDescription: String? {
        switch self {
        case .emptyBlankNodeIdentifier:
            return "Blank node identifier must not be empty."
        case .emptyLanguageTag:
            return "Language tag must not be empty."
        case .languageTagWithDatatype:
            return "Language-tagged strings must not declare a datatype."
        case .textDirectionRequiresLanguageTag:
            return "Text direction requires a language tag."
        case .invalidSubject:
            return "RDF subject must be IRI or BlankNode."
        }
    }
}
