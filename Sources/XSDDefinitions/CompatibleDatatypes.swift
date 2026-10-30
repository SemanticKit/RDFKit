import Foundation

/// The XML Schema datatypes RDF uses, as RDF 1.2 Concepts lists them: the
/// table `tab-xsd-datatypes` of §5.1, "A list of the RDF-compatible XSD
/// types", whose entries are written `xsd:string`, and the namespace the
/// prefix `xsd` stands for, from the table `tab-vocab-ns` of §1.4.
///
/// The specification is an HTML document. Its tables are read as the
/// markup gives them: the element with the table's `id`, up to its
/// `</table>`, and in it the `<td>` and `<code>` contents.
public struct CompatibleDatatypes: Sendable {
    /// The namespace IRI of the XSD datatypes, ending in `#`.
    public let namespace: String

    /// The local names of the datatypes, in the order of the table.
    public let names: [String]

    public init(concepts html: String) throws {
        let prefixes = try Self.table("tab-vocab-ns", in: html)
        let rows = prefixes.components(separatedBy: "<tr").dropFirst()
        var namespace: String?
        for row in rows {
            let cells = Self.contents(of: "td", in: row)
            if cells.count >= 2, Self.text(cells[0]) == "xsd" {
                namespace = Self.text(cells[1])
            }
        }
        guard let namespace else {
            throw DefinitionError(description: "RDF 1.2 Concepts gives no namespace for the prefix xsd in tab-vocab-ns")
        }
        let datatypes = try Self.table("tab-xsd-datatypes", in: html)
        let names = Self.contents(of: "code", in: datatypes).compactMap { code -> String? in
            let text = Self.text(code)
            return text.hasPrefix("xsd:") ? String(text.dropFirst(4)) : nil
        }
        guard !names.isEmpty else {
            throw DefinitionError(description: "RDF 1.2 Concepts lists no datatypes in tab-xsd-datatypes")
        }
        self.namespace = namespace
        self.names = names
    }

    /// The markup of the table with the `id`.
    private static func table(_ id: String, in html: String) throws -> Substring {
        guard let start = html.range(of: "id=\"\(id)\""), let end = html.range(of: "</table>", range: start.upperBound..<html.endIndex) else {
            throw DefinitionError(description: "RDF 1.2 Concepts has no table \(id)")
        }
        return html[start.upperBound..<end.lowerBound]
    }

    /// The contents of each `<name ...>...</name>` element in `markup`.
    private static func contents(of name: String, in markup: some StringProtocol) -> [Substring] {
        let markup = Substring(markup)
        var contents: [Substring] = []
        var rest = markup[...]
        while let open = rest.range(of: "<\(name)") {
            guard let tagEnd = rest.range(of: ">", range: open.upperBound..<rest.endIndex),
                  let close = rest.range(of: "</\(name)>", range: tagEnd.upperBound..<rest.endIndex) else { break }
            contents.append(rest[tagEnd.upperBound..<close.lowerBound])
            rest = rest[close.upperBound...]
        }
        return contents
    }

    /// The text of markup: what remains without its tags, trimmed.
    private static func text(_ markup: some StringProtocol) -> String {
        var text = ""
        var inTag = false
        for character in markup {
            if character == "<" { inTag = true } else if character == ">" { inTag = false } else if !inTag { text.append(character) }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
