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

    /// The value a simple literal denotes: RDF 1.2 Concepts §3.4, "Simple
    /// literals are syntactic sugar for abstract syntax literals with the
    /// datatype IRI http://www.w3.org/2001/XMLSchema#string", and RDFCore's
    /// ``RDFCore/Literal`` keeps such a literal in its simple form, with no
    /// datatype IRI. A language-tagged string is not one.
    public static func ownDenotation(of literal: Literal) -> (value: CharacterSequence, literalForm: LiteralForm)? {
        guard literal.datatype == nil, literal.languageTag == nil else { return nil }
        return writtenDenotation(of: literal.lexicalForm)
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
