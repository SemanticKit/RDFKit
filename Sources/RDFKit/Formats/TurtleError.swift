import Foundation

/// Errors produced while encoding or decoding Turtle RDF graphs.
public enum TurtleError: Error, CustomStringConvertible {
    /// The source ended before a complete Turtle construct was decoded.
    case unexpectedEndOfInput(line: Int, column: Int)

    /// The decoder found a character that is not valid in the current Turtle position.
    case unexpectedCharacter(Character, line: Int, column: Int)

    /// The decoder found a malformed token.
    case invalidToken(String, line: Int, column: Int)

    /// The decoder found a prefixed name whose prefix was not declared.
    case undefinedPrefix(String, line: Int, column: Int)

    /// The supplied base IRI could not be used to resolve relative IRIs.
    case invalidBaseIri(String)

    /// Human-readable error description.
    public var description: String {
        switch self {
        case let .unexpectedEndOfInput(line, column):
            return "Unexpected end of input at line \(line), column \(column)."
        case let .unexpectedCharacter(char, line, column):
            return "Unexpected character '\(char)' at line \(line), column \(column)."
        case let .invalidToken(token, line, column):
            return "Invalid token '\(token)' at line \(line), column \(column)."
        case let .undefinedPrefix(prefix, line, column):
            return "Undefined prefix '\(prefix)' at line \(line), column \(column)."
        case let .invalidBaseIri(value):
            return "Invalid base IRI: \(value)"
        }
    }
}
