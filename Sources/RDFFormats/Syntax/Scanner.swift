import RDFCore

/// A cursor over a document's Unicode scalars, with the terminal productions
/// that N-Triples and Turtle share.
///
/// Positions are scalar offsets. Line and column are computed only when an
/// error is reported.
struct Scanner {
    let scalars: [Unicode.Scalar]
    var index = 0

    init(_ text: String) {
        self.scalars = Array(text.unicodeScalars)
    }

    var isAtEnd: Bool { index >= scalars.count }

    func peek(_ offset: Int = 0) -> Unicode.Scalar? {
        let position = index + offset
        return position < scalars.count ? scalars[position] : nil
    }

    func peek(is value: Unicode.Scalar, at offset: Int = 0) -> Bool {
        peek(offset) == value
    }

    /// Whether the scalars at the cursor spell `text`.
    func peek(spells text: String) -> Bool {
        var offset = 0
        for scalar in text.unicodeScalars {
            guard peek(offset) == scalar else { return false }
            offset += 1
        }
        return true
    }

    mutating func advance(_ count: Int = 1) {
        index += count
    }

    mutating func next() -> Unicode.Scalar? {
        defer { index += 1 }
        return peek()
    }

    /// Consumes `text` if the cursor spells it.
    mutating func consume(_ text: String) -> Bool {
        guard peek(spells: text) else { return false }
        index += text.unicodeScalars.count
        return true
    }

    func error(_ message: String, at position: Int? = nil) -> SyntaxError {
        let position = min(position ?? index, scalars.count)
        var line = 1
        var column = 1
        for scalar in scalars[..<position] {
            if scalar == "\n" {
                line += 1
                column = 1
            } else {
                column += 1
            }
        }
        return SyntaxError(line: line, column: column, message: message)
    }

    // MARK: - IRIREF

    /// `IRIREF ::= '<' ([^#x00-#x20<>"{}|^`\] | UCHAR)* '>'`, returning the
    /// unescaped character sequence between the brackets.
    mutating func scanIRIReference() throws -> String {
        let start = index
        guard consume("<") else { throw error("expected '<'") }
        var value = String.UnicodeScalarView()
        while true {
            guard let scalar = next() else { throw error("unterminated IRI", at: start) }
            switch scalar {
            case ">":
                return String(value)
            case "\\":
                let escaped = try scanUnicodeEscape()
                guard Self.isIRIReferenceCharacter(escaped) else {
                    throw error("escape \\u\(String(escaped.value, radix: 16)) is not allowed in an IRI")
                }
                value.append(escaped)
            default:
                guard Self.isIRIReferenceCharacter(scalar) else {
                    throw error("character U+\(String(scalar.value, radix: 16, uppercase: true)) is not allowed in an IRI", at: index - 1)
                }
                value.append(scalar)
            }
        }
    }

    static func isIRIReferenceCharacter(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar {
        case "\u{00}"..."\u{20}", "<", ">", "\"", "{", "}", "|", "^", "`", "\\": false
        default: true
        }
    }

    // MARK: - Escapes

    /// `UCHAR ::= '\u' HEX HEX HEX HEX | '\U' HEX HEX HEX HEX HEX HEX HEX HEX`,
    /// with the cursor after the backslash.
    mutating func scanUnicodeEscape() throws -> Unicode.Scalar {
        let start = index - 1
        let length: Int
        switch next() {
        case "u": length = 4
        case "U": length = 8
        default: throw error("expected \\u or \\U escape", at: start)
        }
        var value: UInt32 = 0
        for _ in 0..<length {
            guard let digit = peek(), let hex = Self.hexValue(digit) else {
                throw error("expected a hexadecimal digit in escape")
            }
            value = value * 16 + hex
            advance()
        }
        guard let scalar = Unicode.Scalar(value) else {
            throw error("escape names U+\(String(value, radix: 16, uppercase: true)), which is not a Unicode scalar value", at: start)
        }
        return scalar
    }

    static func hexValue(_ scalar: Unicode.Scalar) -> UInt32? {
        switch scalar {
        case "0"..."9": scalar.value - 48
        case "a"..."f": scalar.value - 87
        case "A"..."F": scalar.value - 55
        default: nil
        }
    }

    /// `ECHAR ::= '\' [tbnrf"'\]` or `UCHAR`, with the cursor on the backslash.
    mutating func scanStringEscape() throws -> Unicode.Scalar {
        advance()
        switch peek() {
        case "t": advance(); return "\t"
        case "b": advance(); return "\u{08}"
        case "n": advance(); return "\n"
        case "r": advance(); return "\r"
        case "f": advance(); return "\u{0C}"
        case "\"": advance(); return "\""
        case "'": advance(); return "'"
        case "\\": advance(); return "\\"
        case "u", "U": return try scanUnicodeEscape()
        default: throw error("invalid escape sequence", at: index - 1)
        }
    }

    // MARK: - Strings

    /// Scans a string literal at the cursor.
    ///
    /// `STRING_LITERAL_QUOTE`, and, when `allowsSingleQuotes`, also
    /// `STRING_LITERAL_SINGLE_QUOTE`; when `allowsLongForms`, also the
    /// triple-quoted forms.
    mutating func scanString(allowsSingleQuotes: Bool, allowsLongForms: Bool) throws -> (value: String, isLong: Bool) {
        let start = index
        guard let quote = peek(), quote == "\"" || (allowsSingleQuotes && quote == "'") else {
            throw error("expected a string")
        }
        let isLong = allowsLongForms && peek(is: quote, at: 1) && peek(is: quote, at: 2)
        advance(isLong ? 3 : 1)
        var value = String.UnicodeScalarView()
        while true {
            guard let scalar = peek() else { throw error("unterminated string", at: start) }
            if scalar == quote {
                if !isLong {
                    advance()
                    return (String(value), false)
                }
                if peek(is: quote, at: 1) && peek(is: quote, at: 2) {
                    // The content cannot end with a quote, so the first
                    // three quotes close the string.
                    advance(3)
                    return (String(value), true)
                }
                value.append(scalar)
                advance()
                continue
            }
            switch scalar {
            case "\\":
                value.append(try scanStringEscape())
            case "\n", "\r":
                guard isLong else { throw error("line break in a short string") }
                value.append(scalar)
                advance()
            default:
                value.append(scalar)
                advance()
            }
        }
    }

    // MARK: - LANG_DIR

    /// `LANG_DIR ::= '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)* ('--' [a-zA-Z]+)?`,
    /// returning the scalars after `@` as written.
    mutating func scanAtWord() throws -> String {
        guard consume("@") else { throw error("expected '@'") }
        let start = index
        guard let first = peek(), Self.isASCIILetter(first) else {
            throw error("expected a letter after '@'")
        }
        while let scalar = peek(), Self.isASCIILetter(scalar) { advance() }
        while peek(is: "-") {
            if let following = peek(1), Self.isASCIILetter(following) || Self.isASCIIDigit(following) {
                advance()
                while let scalar = peek(), Self.isASCIILetter(scalar) || Self.isASCIIDigit(scalar) { advance() }
            } else if peek(is: "-", at: 1), let following = peek(2), Self.isASCIILetter(following) {
                advance(2)
                while let scalar = peek(), Self.isASCIILetter(scalar) { advance() }
                break
            } else {
                break
            }
        }
        return String(String.UnicodeScalarView(scalars[start..<index]))
    }

    /// Splits the text after `@` into a language tag and an optional base
    /// direction, rejecting a tag that is not a well-formed BCP 47 shape or a
    /// direction other than `ltr` and `rtl`.
    func languageAndDirection(_ word: String, at position: Int) throws -> (language: String, direction: TextDirection?) {
        let parts = word.components(separatedBy: "--")
        let language = parts[0]
        var direction: TextDirection?
        if parts.count == 2 {
            guard let value = TextDirection(rawValue: parts[1]) else {
                throw error("base direction must be 'ltr' or 'rtl'", at: position)
            }
            direction = value
        }
        for subtag in language.split(separator: "-", omittingEmptySubsequences: false) {
            guard (1...8).contains(subtag.unicodeScalars.count) else {
                throw error("language subtag '\(subtag)' is not 1 to 8 characters long", at: position)
            }
        }
        return (language, direction)
    }

    // MARK: - Blank node labels

    /// `BLANK_NODE_LABEL ::= '_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)?`,
    /// returning the label after `_:`.
    mutating func scanBlankNodeLabel() throws -> String {
        guard consume("_:") else { throw error("expected '_:'") }
        let start = index
        guard let first = peek(), Self.isPNCharsU(first) || Self.isASCIIDigit(first) else {
            throw error("expected a blank node label")
        }
        advance()
        var end = index
        while let scalar = peek(), Self.isPNChars(scalar) || scalar == "." {
            advance()
            if scalar != "." { end = index }
        }
        index = end
        return String(String.UnicodeScalarView(scalars[start..<end]))
    }

    // MARK: - Character classes

    static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        ("a"..."z").contains(scalar) || ("A"..."Z").contains(scalar)
    }

    static func isASCIIDigit(_ scalar: Unicode.Scalar) -> Bool {
        ("0"..."9").contains(scalar)
    }

    static func isHexDigit(_ scalar: Unicode.Scalar) -> Bool {
        hexValue(scalar) != nil
    }

    /// `PN_CHARS_BASE`.
    static func isPNCharsBase(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x41...0x5A, 0x61...0x7A,
             0x00C0...0x00D6, 0x00D8...0x00F6, 0x00F8...0x02FF,
             0x0370...0x037D, 0x037F...0x1FFF, 0x200C...0x200D,
             0x2070...0x218F, 0x2C00...0x2FEF, 0x3001...0xD7FF,
             0xF900...0xFDCF, 0xFDF0...0xFFFD, 0x10000...0xEFFFF:
            true
        default:
            false
        }
    }

    /// `PN_CHARS_U ::= PN_CHARS_BASE | '_'`.
    static func isPNCharsU(_ scalar: Unicode.Scalar) -> Bool {
        scalar == "_" || isPNCharsBase(scalar)
    }

    /// `PN_CHARS ::= PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]`.
    static func isPNChars(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x2D, 0x30...0x39, 0xB7, 0x0300...0x036F, 0x203F...0x2040: true
        default: isPNCharsU(scalar)
        }
    }
}
