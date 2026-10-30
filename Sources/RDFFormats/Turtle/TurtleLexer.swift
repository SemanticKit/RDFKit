/// Splits a Turtle document into ``TurtleToken``s, skipping white space and
/// comments (RDF 1.2 Turtle §7.3).
struct TurtleLexer {
    var scanner: Scanner

    init(_ document: String) {
        scanner = Scanner(document)
    }

    /// `WS ::= #x20 | #x9 | #xD | #xA`, and comments from `#` to the line end.
    mutating func skipWhiteSpace() {
        while let scalar = scanner.peek() {
            switch scalar {
            case " ", "\t", "\r", "\n":
                scanner.advance()
            case "#":
                while let scalar = scanner.peek(), scalar != "\n", scalar != "\r" { scanner.advance() }
            default:
                return
            }
        }
    }

    /// Reads the next token and the scalar offset it starts at.
    mutating func next() throws -> (token: TurtleToken, position: Int) {
        skipWhiteSpace()
        let position = scanner.index
        guard let scalar = scanner.peek() else { return (.end, position) }
        let token: TurtleToken
        switch scalar {
        case "<":
            if scanner.consume("<<(") {
                token = .punctuation("<<(")
            } else if scanner.consume("<<") {
                token = .punctuation("<<")
            } else {
                token = .iriReference(try scanner.scanIRIReference())
            }
        case ">":
            guard scanner.consume(">>") else { throw scanner.error("unexpected '>'") }
            token = .punctuation(">>")
        case ")":
            if scanner.consume(")>>") {
                token = .punctuation(")>>")
            } else {
                scanner.advance()
                token = .punctuation(")")
            }
        case "{":
            guard scanner.consume("{|") else { throw scanner.error("unexpected '{'") }
            token = .punctuation("{|")
        case "|":
            guard scanner.consume("|}") else { throw scanner.error("unexpected '|'") }
            token = .punctuation("|}")
        case "^":
            guard scanner.consume("^^") else { throw scanner.error("unexpected '^'") }
            token = .punctuation("^^")
        case ".", ";", ",", "[", "]", "(", "~":
            if scalar == ".", let following = scanner.peek(1), Scanner.isASCIIDigit(following) {
                token = try scanNumber()
            } else {
                scanner.advance()
                token = .punctuation(String(scalar))
            }
        case "\"", "'":
            let (value, isLong) = try scanner.scanTurtleString()
            token = .string(value, isLong: isLong)
        case "@":
            token = .atWord(try scanner.scanAtWord())
        case "_" where scanner.peek(is: ":", at: 1):
            token = .blankNodeLabel(try scanner.scanBlankNodeLabel())
        case "+", "-", "0"..."9":
            token = try scanNumber()
        case ":":
            token = try scanPrefixedName(prefix: "")
        default:
            guard Scanner.isPNCharsBase(scalar) else {
                throw scanner.error("unexpected character U+\(String(scalar.value, radix: 16, uppercase: true))")
            }
            token = try scanNameOrPrefixedName()
        }
        return (token, position)
    }

    // MARK: - Numbers

    /// `INTEGER`, `DECIMAL` and `DOUBLE`.
    mutating func scanNumber() throws -> TurtleToken {
        let start = scanner.index
        if scanner.peek(is: "+") || scanner.peek(is: "-") { scanner.advance() }
        var integerDigits = 0
        while let scalar = scanner.peek(), Scanner.isASCIIDigit(scalar) {
            scanner.advance()
            integerDigits += 1
        }
        var fractionDigits = 0
        var hasPoint = false
        // A '.' belongs to the number only when a digit or a valid exponent
        // follows; otherwise it ends the statement.
        if scanner.peek(is: "."),
           let following = scanner.peek(1),
           Scanner.isASCIIDigit(following) || (integerDigits > 0 && isExponent(at: 1)) {
            scanner.advance()
            hasPoint = true
            while let scalar = scanner.peek(), Scanner.isASCIIDigit(scalar) {
                scanner.advance()
                fractionDigits += 1
            }
        }
        guard integerDigits + fractionDigits > 0 else {
            throw scanner.error("expected a number", at: start)
        }
        var hasExponent = false
        if isExponent(at: 0) {
            scanner.advance()
            if scanner.peek(is: "+") || scanner.peek(is: "-") { scanner.advance() }
            while let scalar = scanner.peek(), Scanner.isASCIIDigit(scalar) { scanner.advance() }
            hasExponent = true
        }
        let text = String(String.UnicodeScalarView(scanner.scalars[start..<scanner.index]))
        if hasExponent { return .double(text) }
        if hasPoint { return .decimal(text) }
        return .integer(text)
    }

    /// `EXPONENT ::= [eE] [+-]? [0-9]+` at `offset` from the cursor.
    func isExponent(at offset: Int) -> Bool {
        guard scanner.peek(is: "e", at: offset) || scanner.peek(is: "E", at: offset) else { return false }
        var position = offset + 1
        if scanner.peek(is: "+", at: position) || scanner.peek(is: "-", at: position) { position += 1 }
        guard let digit = scanner.peek(position) else { return false }
        return Scanner.isASCIIDigit(digit)
    }

    // MARK: - Names

    /// A bare word, or `PNAME_NS` / `PNAME_LN` when a `:` follows the
    /// `PN_PREFIX`.
    mutating func scanNameOrPrefixedName() throws -> TurtleToken {
        let start = scanner.index
        scanner.advance()
        var end = scanner.index
        while let scalar = scanner.peek(), Scanner.isPNChars(scalar) || scalar == "." {
            scanner.advance()
            if scalar != "." { end = scanner.index }
        }
        scanner.index = end
        let name = String(String.UnicodeScalarView(scanner.scalars[start..<end]))
        if scanner.peek(is: ":") {
            return try scanPrefixedName(prefix: name)
        }
        return .word(name)
    }

    /// The `:` and the optional `PN_LOCAL` after a prefix.
    ///
    /// `PN_LOCAL ::= (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))?`
    mutating func scanPrefixedName(prefix: String) throws -> TurtleToken {
        guard scanner.consume(":") else { throw scanner.error("expected ':'") }
        var local = String.UnicodeScalarView()
        var committed = String.UnicodeScalarView()
        var committedIndex = scanner.index
        var isFirst = true
        while let scalar = scanner.peek() {
            if scalar == "%" {
                guard let high = scanner.peek(1), Scanner.isHexDigit(high),
                      let low = scanner.peek(2), Scanner.isHexDigit(low) else {
                    throw scanner.error("expected two hexadecimal digits after '%'")
                }
                local.append(contentsOf: [scalar, high, low])
                scanner.advance(3)
            } else if scalar == "\\" {
                guard let escaped = scanner.peek(1), Self.isLocalEscape(escaped) else {
                    throw scanner.error("invalid escape in a local name")
                }
                local.append(escaped)
                scanner.advance(2)
            } else if scalar == "." && !isFirst {
                local.append(scalar)
                scanner.advance()
                isFirst = false
                continue
            } else if Scanner.isPNChars(scalar) || scalar == ":" {
                if isFirst && !(Scanner.isPNCharsU(scalar) || scalar == ":" || Scanner.isASCIIDigit(scalar)) {
                    break
                }
                local.append(scalar)
                scanner.advance()
            } else {
                break
            }
            isFirst = false
            committed = local
            committedIndex = scanner.index
        }
        // A local name cannot end with '.'; leave trailing dots for the parser.
        scanner.index = committedIndex
        return .prefixedName(prefix: prefix, local: String(committed))
    }

    /// `PN_LOCAL_ESC ::= '\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%')`
    static func isLocalEscape(_ scalar: Unicode.Scalar) -> Bool {
        "_~.-!$&'()*+,;=/?#@%".unicodeScalars.contains(scalar)
    }
}
