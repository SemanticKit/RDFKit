import IRIKit
import RDFCore

extension Literal {
    /// Creates a typed literal.
    ///
    /// RDF 1.2 Concepts §3.4 Literals: the datatype IRI of a simple literal is
    /// `xsd:string`, so `Literal("a", datatype: xsd:string)` is the same
    /// literal as `Literal("a")`. A language-tagged string carries its
    /// datatype through its language tag, so `rdf:langString` and
    /// `rdf:dirLangString` need one.
    ///
    /// - Throws: ``TermError/datatypeRequiresLanguageTag`` for
    ///   `rdf:langString` and `rdf:dirLangString`.
    public init(_ lexicalForm: String, datatype: IRI) throws(TermError) {
        if datatype == XSD.string.metadata.id {
            self.init(lexicalForm)
        } else if datatype == RDF.langString.metadata.id || datatype == RDF.dirLangString.metadata.id {
            throw .datatypeRequiresLanguageTag
        } else {
            self.init(lexicalForm: lexicalForm, datatype: datatype)
        }
    }

    /// The literal's datatype IRI as RDF 1.2 Concepts §3.4 gives it:
    /// `rdf:dirLangString` for a directional language-tagged string,
    /// `rdf:langString` for any other language-tagged string, `xsd:string`
    /// for a simple literal, and ``datatype`` otherwise.
    public var datatypeIRI: IRI {
        if languageTag != nil {
            return baseDirection == nil ? RDF.langString.metadata.id : RDF.dirLangString.metadata.id
        }
        return datatype ?? XSD.string.metadata.id
    }
}
