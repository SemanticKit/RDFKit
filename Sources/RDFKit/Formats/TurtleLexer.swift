import Foundation

/// Reads Turtle source one character at a time while tracking source locations.
struct TurtleLexer {
    private let text: String
    private var index: String.Index
    private(set) var line: Int = 1
    private(set) var column: Int = 1

    /// Creates a lexer over Turtle source.
    init(_ text: String) {
        self.text = text
        self.index = text.startIndex
    }

    /// A Boolean value indicating whether every source character has been consumed.
    var isAtEnd: Bool {
        index >= text.endIndex
    }

    /// Advances past whitespace and Turtle comments.
    mutating func skipWhitespaceAndComments() {
        while let ch = peek() {
            if ch == "#" {
                skipComment()
            } else if ch.isWhitespace {
                _ = advance()
            } else {
                break
            }
        }
    }

    private mutating func skipComment() {
        while let ch = advance() {
            if ch == "\n" { break }
        }
    }

    /// Returns the current character without consuming it.
    func peek() -> Character? {
        guard index < text.endIndex else { return nil }
        return text[index]
    }

    /// Returns the next character without consuming it.
    func peekNext() -> Character? {
        guard index < text.endIndex else { return nil }
        let nextIndex = text.index(after: index)
        guard nextIndex < text.endIndex else { return nil }
        return text[nextIndex]
    }

    /// Returns the character at the requested offset without consuming it.
    func peek(after offset: Int) -> Character? {
        guard offset > 0 else { return peek() }
        var cursor = index
        for _ in 0..<offset {
            if cursor >= text.endIndex { return nil }
            cursor = text.index(after: cursor)
        }
        return cursor < text.endIndex ? text[cursor] : nil
    }

    /// Consumes and returns the current character.
    mutating func advance() -> Character? {
        guard index < text.endIndex else { return nil }
        let ch = text[index]
        index = text.index(after: index)
        if ch == "\n" {
            line += 1
            column = 1
        } else {
            column += 1
        }
        return ch
    }

    /// Consumes the exact string or throws a source-positioned Turtle error.
    mutating func expect(_ string: String) throws {
        for ch in string {
            guard let current = peek(), current == ch else {
                throw errorUnexpectedCharacter()
            }
            _ = advance()
        }
    }

    /// Returns whether the current source starts with the string.
    func starts(with string: String, caseInsensitive: Bool = false) -> Bool {
        let substring = String(text[index...].prefix(string.count))
        if caseInsensitive {
            return substring.lowercased() == string.lowercased()
        }
        return substring == string
    }

    /// Consumes a word if it appears at the current location.
    mutating func consumeWord(_ word: String, caseInsensitive: Bool, wordBoundary: Bool = false) -> Bool {
        let originalIndex = index
        let originalLine = line
        let originalColumn = column

        if starts(with: word, caseInsensitive: caseInsensitive) {
            for _ in word { _ = advance() }
            if wordBoundary {
                if let ch = peek(), ch.isLetter || ch.isNumber || ch == "_" {
                    index = originalIndex
                    line = originalLine
                    column = originalColumn
                    return false
                }
            }
            return true
        }
        return false
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
    func errorUnexpectedEnd() -> TurtleError {
        TurtleError.unexpectedEndOfInput(line: line, column: column)
    }

    /// Creates an unexpected-character error at the current source location.
    func errorUnexpectedCharacter() -> TurtleError {
        if let ch = peek() {
            return TurtleError.unexpectedCharacter(ch, line: line, column: column)
        }
        return TurtleError.unexpectedEndOfInput(line: line, column: column)
    }

    /// Creates an invalid-token error at the current source location.
    func errorUnexpectedToken(_ token: String) -> TurtleError {
        TurtleError.invalidToken(token, line: line, column: column)
    }

    /// Creates an undefined-prefix error at the current source location.
    func errorUndefinedPrefix(_ prefix: String) -> TurtleError {
        TurtleError.undefinedPrefix(prefix, line: line, column: column)
    }
}
