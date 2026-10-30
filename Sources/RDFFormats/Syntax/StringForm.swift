/// The string productions of RDF 1.2 Turtle (§7.3). N-Triples has only
/// ``quote``, `STRING_LITERAL_QUOTE` (RDF 1.2 N-Triples §7).
enum StringForm: CaseIterable {
    /// `STRING_LITERAL_QUOTE`: `"..."`.
    case quote
    /// `STRING_LITERAL_SINGLE_QUOTE`: `'...'`.
    case singleQuote
    /// `STRING_LITERAL_LONG_QUOTE`: `"""..."""`.
    case longQuote
    /// `STRING_LITERAL_LONG_SINGLE_QUOTE`: `'''...'''`.
    case longSingleQuote

    /// The form whose opening delimiter is at the scanner's cursor, a long
    /// form before a short one, or `nil` when no string starts there.
    init?(at scanner: Scanner) {
        guard let form = [Self.longQuote, .longSingleQuote, .quote, .singleQuote]
            .first(where: { scanner.peek(spells: $0.delimiter) }) else { return nil }
        self = form
    }

    /// The delimiter that opens and closes the string.
    var delimiter: String {
        switch self {
        case .quote: "\""
        case .singleQuote: "'"
        case .longQuote: "\"\"\""
        case .longSingleQuote: "'''"
        }
    }

    /// Whether the string may hold a line feed or carriage return as
    /// written: only the long forms may.
    var allowsLineBreaks: Bool {
        switch self {
        case .quote, .singleQuote: false
        case .longQuote, .longSingleQuote: true
        }
    }
}
