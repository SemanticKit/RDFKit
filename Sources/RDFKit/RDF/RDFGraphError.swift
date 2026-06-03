import Foundation

/// Errors thrown by graph storage operations.
public enum RDFGraphError: Error, CustomStringConvertible {
    /// The subject was invalid.
    case invalidSubject

    /// The predicate was invalid.
    case invalidPredicate

    /// The triple already exists.
    case duplicateTriple

    public var description: String {
        switch self {
        case .invalidSubject:
            return "Subject must be IRI or BlankNode."
        case .invalidPredicate:
            return "Predicate must be an IRI."
        case .duplicateTriple:
            return "Triple already present in the graph."
        }
    }
}
