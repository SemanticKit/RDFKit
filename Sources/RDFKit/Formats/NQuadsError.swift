import Foundation

/// Errors produced while encoding or decoding N-Quads RDF datasets.
public enum NQuadsError: Error, CustomStringConvertible {
    /// The source ended before a complete N-Quads construct was decoded.
    case unexpectedEndOfInput(line: Int, column: Int)

    /// The decoder found a character that is not valid in the current position.
    case unexpectedCharacter(Character, line: Int, column: Int)

    /// The decoder found a malformed token.
    case invalidToken(String, line: Int, column: Int)

    /// The decoder found a graph name that is not an IRI.
    case invalidGraphName(line: Int, column: Int)

    /// Human-readable error description.
    public var description: String {
        switch self {
        case let .unexpectedEndOfInput(line, column):
            return "Unexpected end of input at line \(line), column \(column)."
        case let .unexpectedCharacter(char, line, column):
            return "Unexpected character '\(char)' at line \(line), column \(column)."
        case let .invalidToken(token, line, column):
            return "Invalid token '\(token)' at line \(line), column \(column)."
        case let .invalidGraphName(line, column):
            return "Invalid graph name at line \(line), column \(column). Graph names must be IRIs."
        }
    }
}
