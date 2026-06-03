import Foundation

/// Reads OWL Functional-Style Syntax source while tracking source locations.
struct OWLFunctionalSyntaxLexer {
    private let text: String
    private var index: String.Index
    private(set) var line: Int = 1
    private(set) var column: Int = 1

    /// Creates a lexer over OWL Functional-Style Syntax source.
    init(_ text: String) {
        self.text = text
        self.index = text.startIndex
    }

    /// A Boolean value indicating whether every source character has been consumed.
    var isAtEnd: Bool { index >= text.endIndex }

    /// Returns the current character without consuming it.
    func peek() -> Character? {
        guard index < text.endIndex else { return nil }
        return text[index]
    }

    /// Returns whether the current source starts with the string.
    func starts(with string: String) -> Bool {
        String(text[index...].prefix(string.count)) == string
    }

    /// Consumes and returns the current character.
    @discardableResult
    mutating func advance() -> Character? {
        guard index < text.endIndex else { return nil }
        let ch = text[index]
        index = text.index(after: index)
        if ch == "\n" || ch == "\r" {
            line += 1
            column = 1
        } else {
            column += 1
        }
        return ch
    }

    /// Advances past whitespace and comments.
    mutating func skipWhitespaceAndComments() {
        while let ch = peek() {
            if ch == "#" {
                skipComment()
                continue
            }
            if ch.isWhitespace {
                _ = advance()
                continue
            }
            break
        }
    }

    /// Consumes the exact string or throws a source-positioned error.
    mutating func expect(_ string: String) throws {
        for ch in string {
            guard let current = peek(), current == ch else {
                throw errorUnexpectedCharacter()
            }
            _ = advance()
        }
    }

    /// Consumes a word if it appears at the current location.
    mutating func consumeWord(_ word: String) -> Bool {
        let snapshot = index
        let snapLine = line
        let snapColumn = column
        if starts(with: word) {
            for _ in word { _ = advance() }
            return true
        }
        index = snapshot
        line = snapLine
        column = snapColumn
        return false
    }

    /// Returns whether the current token can start an IRI reference.
    func isStartOfIriRef() -> Bool {
        if peek() == "<" { return true }
        if starts(with: "_:") { return true }
        if peek() == ":" { return true }
        var token = ""
        var scanIndex = index
        while scanIndex < text.endIndex {
            let ch = text[scanIndex]
            if ch.isWhitespace || ch == "(" || ch == ")" {
                break
            }
            token.append(ch)
            scanIndex = text.index(after: scanIndex)
        }
        return token.contains(":")
    }

    /// Reads a fixed-width escaped Unicode scalar.
    mutating func readUnicodeScalar(count: Int) throws -> String {
        var hex = ""
        for _ in 0..<count {
            guard let ch = advance() else { throw errorUnexpectedEnd() }
            hex.append(ch)
        }
        guard let value = UInt32(hex, radix: 16), let scalar = UnicodeScalar(value) else {
            throw errorUnexpectedToken(hex)
        }
        return String(scalar)
    }

    /// Creates an unexpected-end error at the current source location.
    func errorUnexpectedEnd() -> OWLFunctionalSyntaxError {
        .unexpectedEndOfInput(line: line, column: column)
    }

    /// Creates an unexpected-character error at the current source location.
    func errorUnexpectedCharacter() -> OWLFunctionalSyntaxError {
        let ch = peek() ?? "\0"
        return .unexpectedCharacter(ch, line: line, column: column)
    }

    /// Creates an unexpected-token error at the current source location.
    func errorUnexpectedToken(_ token: String) -> OWLFunctionalSyntaxError {
        .unexpectedToken(token, line: line, column: column)
    }

    /// Creates an undefined-prefix error at the current source location.
    func errorUndefinedPrefix(_ prefix: String) -> OWLFunctionalSyntaxError {
        .undefinedPrefix(prefix, line: line, column: column)
    }

    /// Creates an unsupported-construct error at the current source location.
    func errorUnsupported(_ name: String) -> OWLFunctionalSyntaxError {
        .unsupportedConstruct(name, line: line, column: column)
    }

    private mutating func skipComment() {
        while let ch = advance() {
            if ch == "\n" || ch == "\r" { break }
        }
    }
}
