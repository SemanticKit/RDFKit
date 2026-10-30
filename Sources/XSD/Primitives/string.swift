import RDFCore

/// `xsd:string` (XML Schema 1.1 Part 2 §3.3.1): finite sequences of
/// characters, each its own lexical representation.
extension string {
    public typealias Value = CharacterSequence

    /// ·stringLexicalMap·: the identity, on strings of XML characters.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> CharacterSequence {
        guard CharacterSequence.isXMLCharacters(lexicalForm) else { throw .illTyped }
        return CharacterSequence(lexicalForm)
    }

    /// ·stringCanonicalMap·: the identity.
    public static func representations(of value: CharacterSequence) -> [String] {
        [value.text]
    }
}

extension string: ExpressibleByStringLiteral {
    /// The string, which must hold only XML characters (§3.3.1).
    public init(stringLiteral text: String) {
        do {
            try self.init(lexicalForm: text)
        } catch {
            preconditionFailure("\(text.debugDescription) holds a character outside XML's Char production")
        }
    }
}

extension CharacterSequence: FacetMeasurable {
    public var facetLength: Int? { count }
}
