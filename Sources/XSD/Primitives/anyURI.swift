import RDFCore

/// `xsd:anyURI` (XML Schema 1.1 Part 2 §3.3.17): "The ·lexical space· of
/// anyURI is the set of finite-length sequences of zero or more characters
/// (as defined in [XML]) that ·match· the Char production from [XML]", and
/// its value space is the same sequences.
extension anyURI {
    public typealias Value = CharacterSequence

    /// The identity, on strings of XML characters.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> CharacterSequence {
        guard CharacterSequence.isXMLCharacters(lexicalForm) else { throw .illTyped }
        return CharacterSequence(lexicalForm)
    }

    /// The identity: each value is its own canonical representation.
    public static func representations(of value: CharacterSequence) -> [String] {
        [value.text]
    }
}
