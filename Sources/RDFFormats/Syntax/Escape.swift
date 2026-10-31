/// An escape in the text of a terminal: where it is, in Unicode scalars
/// from the start of the terminal, and the character it stands for.
///
/// RDF 1.2 Turtle §6.4 Escape Sequences, which N-Triples follows (RDF 1.2
/// N-Triples §5.3: "Escape sequence rules are the same as Turtle"): a
/// numeric escape (`UCHAR`) "represents the value of a Unicode code point",
/// a string escape (`ECHAR`) the character its table gives, and a reserved
/// character escape (`PN_LOCAL_ESC`) the character after the backslash.
struct Escape {
    let range: Range<Int>
    let scalar: Unicode.Scalar

    /// The text of a terminal between its delimiters, `delimiter` scalars
    /// at each end, with each of `escapes` replaced by its character.
    static func unescaped(_ text: String, delimiter: Int, _ escapes: [Escape]) -> String {
        let scalars = Array(text.unicodeScalars)
        var result = String.UnicodeScalarView()
        var offset = delimiter
        for escape in escapes.sorted(by: { $0.range.lowerBound < $1.range.lowerBound }) {
            result.append(contentsOf: scalars[offset..<escape.range.lowerBound])
            result.append(escape.scalar)
            offset = escape.range.upperBound
        }
        result.append(contentsOf: scalars[offset..<(scalars.count - delimiter)])
        return String(result)
    }
}

extension Unicode.Scalar {
    /// The character a numeric escape names: its hexadecimal digits as a
    /// code point. `nil` when the code point is not a Unicode scalar value.
    init?(hexadecimal digits: [String]) {
        guard let value = UInt32(digits.joined(), radix: 16), let scalar = Unicode.Scalar(value) else { return nil }
        self = scalar
    }

    /// The character a string escape, `\` and one character, stands for, as
    /// the table of RDF 1.2 Turtle §6.4 gives it.
    init(stringEscape text: String) {
        switch text.unicodeScalars.last {
        case "t": self = "\t"
        case "b": self = "\u{08}"
        case "n": self = "\n"
        case "r": self = "\r"
        case "f": self = "\u{0C}"
        case let scalar?: self = scalar
        case nil: self = "\\"
        }
    }
}
