/// How a value of a datatype is written as a literal: a lexical form and the
/// declared key of the literal's datatype, from which an encoder derives the
/// datatype IRI at the boundary (RDF 1.2 Concepts §3.4: "a literal ...
/// consists of ... a lexical form ... a datatype IRI").
///
/// A value decoded from `"212"^^xsd:integer` for a property whose range is
/// `xsd:nonNegativeInteger` is the `xsd:nonNegativeInteger` 212, written
/// `212` with the key of `xsd:integer`, so the document decodes and encodes
/// back to the same graph. A value made in Swift is written in its canonical
/// form, with its own datatype.
public struct LiteralForm: Sendable {
    /// The lexical form.
    public let lexicalForm: String

    /// The declared key of the literal's datatype.
    public let datatype: TermKey

    public init(lexicalForm: String, datatype: TermKey) {
        self.lexicalForm = lexicalForm
        self.datatype = datatype
    }
}
