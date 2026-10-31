/// A finite sequence of characters: the value space of `xsd:string` and of
/// `xsd:anyURI` (XML Schema 1.1 Part 2 §3.3.1: "The ·value space· of string
/// is the set of finite-length sequences of characters ... that ·match·
/// the Char production from [XML]"; §3.3.17 gives anyURI the same set).
///
/// A character is a code point, so two sequences are equal when their
/// Unicode scalars are, never by Swift `String`'s canonical equivalence:
/// `"\u{E9}"` and `"e\u{301}"` are different strings, as RDF 1.2 Concepts
/// compares lexical forms "character by character".
public struct CharacterSequence: Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral {
    /// The characters.
    public let text: String

    public init(_ text: String) {
        self.text = text
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// The number of characters, the measure the length facets constrain
    /// for strings (§4.3.1).
    public var count: Int { text.unicodeScalars.count }

    public var description: String { text }

    public static func == (lhs: CharacterSequence, rhs: CharacterSequence) -> Bool {
        lhs.text.unicodeScalars.elementsEqual(rhs.text.unicodeScalars)
    }

    public func hash(into hasher: inout Hasher) {
        for scalar in text.unicodeScalars { hasher.combine(scalar.value) }
    }

    /// Whether every character matches the `Char` production of XML 1.0
    /// (§2.2): `#x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] |
    /// [#x10000-#x10FFFF]`, which the string lexical space requires.
    static func isXMLCharacters(_ text: some StringProtocol) -> Bool {
        text.unicodeScalars.allSatisfy { scalar in
            switch scalar.value {
            case 0x9, 0xA, 0xD, 0x20...0xD7FF, 0xE000...0xFFFD, 0x10000...0x10FFFF: true
            default: false
            }
        }
    }
}
