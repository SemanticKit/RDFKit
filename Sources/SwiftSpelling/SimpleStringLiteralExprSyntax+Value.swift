import SwiftSyntax

extension SimpleStringLiteralExprSyntax {
    /// A string literal whose value is `value`.
    ///
    /// The grammar takes a simple string literal, one with no raw
    /// delimiters, in `@available(message:)` and `#sourceLocation(file:)`.
    /// `StringLiteralExprSyntax(content:)` cannot build one there: it writes
    /// a text containing `\` or `"` as a raw literal, `#"…"#`, which those
    /// positions reject. So the characters a string literal cannot hold as
    /// written are escaped here, as `StringLiteralExprSyntax(content:)`
    /// escapes them without a delimiter: `\` and `"`, line breaks, and the
    /// ASCII control characters (The Swift Programming Language, Lexical
    /// Structure, String Literals).
    public init(value: String) {
        self.init(
            openingQuote: .stringQuoteToken(),
            segments: [StringSegmentSyntax(content: .stringSegment(Self.escaped(value)))],
            closingQuote: .stringQuoteToken()
        )
    }

    /// A string literal whose text is the characters of `value` as they are,
    /// or nil when one of them has to be escaped: `"Zoo.swift"`, but no
    /// literal for `a\b` or `a"b`.
    ///
    /// The compiler takes the file name of `#sourceLocation(file:)` as
    /// written, without reading its escapes (swiftc 6.4 records
    /// `#sourceLocation(file: "a\\b", line: 1)` as the file `a\\b`), and
    /// rejects a raw literal there ("'#sourceLocation' cannot be an extended
    /// escaping string literal"). Only a name that needs no escape can be
    /// given to it.
    public init?(verbatim value: String) {
        let literal = SimpleStringLiteralExprSyntax(value: value)
        guard literal.segments.allSatisfy({ $0.content.text == value }) else { return nil }
        self = literal
    }

    private static func escaped(_ value: String) -> String {
        var result = String.UnicodeScalarView()
        for scalar in value.unicodeScalars {
            switch scalar {
            case "\\": result += "\\\\".unicodeScalars
            case "\"": result += "\\\"".unicodeScalars
            case "\n": result += "\\n".unicodeScalars
            case "\r": result += "\\r".unicodeScalars
            case "\t": result += "\\t".unicodeScalars
            case "\0": result += "\\0".unicodeScalars
            case _ where Character(scalar).isNewline || (scalar.isASCII && (scalar.value < 0x20 || scalar.value == 0x7F)):
                result += "\\u{\(String(scalar.value, radix: 16))}".unicodeScalars
            default:
                result.append(scalar)
            }
        }
        return String(result)
    }
}
