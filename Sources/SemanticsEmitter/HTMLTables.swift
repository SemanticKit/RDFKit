/// The tables of an HTML document, each row its cells' text (HTML Living
/// Standard §4.9, "Tabular data"): the text of a cell is its content with
/// the tags left out, character references replaced (§13.5) and white space
/// collapsed.
struct HTMLTables {
    struct Table {
        /// The table's `id` attribute.
        let id: String?
        let rows: [[String]]
    }

    let tables: [Table]

    init(_ document: String) {
        let tablePattern = /<table\b(?<attributes>[^>]*)>(?<content>.*?)<\/table>/.dotMatchesNewlines().ignoresCase()
        let rowPattern = /<tr\b[^>]*>(?<content>.*?)<\/tr>/.dotMatchesNewlines().ignoresCase()
        let cellPattern = /<t[dh]\b[^>]*>(?<content>.*?)<\/t[dh]>/.dotMatchesNewlines().ignoresCase()
        let idPattern = /\bid="(?<id>[^"]*)"/
        tables = document.matches(of: tablePattern).map { table in
            Table(
                id: table.attributes.firstMatch(of: idPattern).map { String($0.id) },
                rows: table.content.matches(of: rowPattern).map { row in
                    row.content.matches(of: cellPattern).map { Self.text(of: $0.content) }
                }
            )
        }
    }

    /// The text of HTML content.
    static func text(of content: Substring) -> String {
        let withoutTags = content.replacing(/<[^>]+>/, with: " ")
        var text = ""
        var rest = withoutTags[...]
        while let ampersand = rest.firstIndex(of: "&") {
            text += rest[..<ampersand]
            let reference = rest[ampersand...]
            if let match = reference.prefixMatch(of: /&(?<name>#[0-9]+|#[xX][0-9a-fA-F]+|[A-Za-z]+);/), let character = character(for: match.name) {
                text.append(character)
                rest = reference[match.range.upperBound...]
            } else {
                text.append("&")
                rest = reference.dropFirst()
            }
        }
        text += rest
        return text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    /// The character a reference names: numeric (`&#8838;`), or one of the
    /// named character references (§13.5) the documents use.
    static func character(for name: Substring) -> Character? {
        if name.hasPrefix("#x") || name.hasPrefix("#X") {
            return UInt32(name.dropFirst(2), radix: 16).flatMap(Unicode.Scalar.init).map(Character.init)
        }
        if name.hasPrefix("#") {
            return UInt32(name.dropFirst()).flatMap(Unicode.Scalar.init).map(Character.init)
        }
        return namedReferences[String(name)]
    }

    /// The named character references of the HTML Living Standard (§13.5)
    /// that the W3C documents read here use.
    static let namedReferences: [String: Character] = [
        "amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": "\u{00A0}",
        "isin": "∈", "notin": "∉", "sube": "⊆", "sub": "⊂", "empty": "∅", "times": "×",
        "hellip": "…", "le": "≤", "ge": "≥", "ne": "≠", "cap": "∩", "cup": "∪",
        "forall": "∀", "exist": "∃", "sdot": "⋅", "Delta": "Δ", "ndash": "–", "mdash": "—",
    ]
}
