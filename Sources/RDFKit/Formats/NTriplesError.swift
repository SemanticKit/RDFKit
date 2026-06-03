import Foundation

/// Errors produced while encoding or decoding N-Triples RDF graphs.
public enum NTriplesError: Error, CustomStringConvertible {
    /// The source ended before a complete N-Triples construct was decoded.
    case unexpectedEndOfInput(line: Int, column: Int)

    /// The decoder found a character that is not valid in the current position.
    case unexpectedCharacter(Character, line: Int, column: Int)

    /// The decoder found a malformed token.
    case invalidToken(String, line: Int, column: Int)

    /// The decoder found a malformed blank node label.
    case invalidBlankNodeLabel(line: Int, column: Int)

    /// The decoder found a malformed language tag.
    case invalidLanguageTag(line: Int, column: Int)

    /// The decoder found a malformed IRI reference.
    case invalidIriRef(line: Int, column: Int)

    /// Human-readable error description.
    public var description: String {
        switch self {
        case let .unexpectedEndOfInput(line, column):
            return "Unexpected end of input at line \(line), column \(column)."
        case let .unexpectedCharacter(char, line, column):
            return "Unexpected character '\(char)' at line \(line), column \(column)."
        case let .invalidToken(token, line, column):
            return "Invalid token '\(token)' at line \(line), column \(column)."
        case let .invalidBlankNodeLabel(line, column):
            return "Invalid blank node label at line \(line), column \(column)."
        case let .invalidLanguageTag(line, column):
            return "Invalid language tag at line \(line), column \(column)."
        case let .invalidIriRef(line, column):
            return "Invalid IRI reference at line \(line), column \(column)."
        }
    }
}
