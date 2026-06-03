import Foundation

/// Errors produced while decoding OWL 2 Functional-Style Syntax.
public enum OWLFunctionalSyntaxError: Error, CustomStringConvertible {
    /// The source ended before a complete construct was decoded.
    case unexpectedEndOfInput(line: Int, column: Int)

    /// The decoder found a character that is not valid in the current position.
    case unexpectedCharacter(Character, line: Int, column: Int)

    /// The decoder found an unexpected token.
    case unexpectedToken(String, line: Int, column: Int)

    /// The decoder found a prefixed name whose prefix was not declared.
    case undefinedPrefix(String, line: Int, column: Int)

    /// An IRI token was malformed.
    case invalidIri(String)

    /// A literal token was malformed.
    case invalidLiteral(String)

    /// The decoder encountered a supported grammar position with an unsupported OWL construct.
    case unsupportedConstruct(String, line: Int, column: Int)

    /// Human-readable error description.
    public var description: String {
        switch self {
        case let .unexpectedEndOfInput(line, column):
            return "Unexpected end of input at line \(line), column \(column)."
        case let .unexpectedCharacter(ch, line, column):
            return "Unexpected character '\(ch)' at line \(line), column \(column)."
        case let .unexpectedToken(token, line, column):
            return "Unexpected token '\(token)' at line \(line), column \(column)."
        case let .undefinedPrefix(prefix, line, column):
            return "Undefined prefix '\(prefix)' at line \(line), column \(column)."
        case let .invalidIri(value):
            return "Invalid IRI: \(value)"
        case let .invalidLiteral(value):
            return "Invalid literal: \(value)"
        case let .unsupportedConstruct(name, line, column):
            return "Unsupported OWL construct '\(name)' at line \(line), column \(column)."
        }
    }
}
