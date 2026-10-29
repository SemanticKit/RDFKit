import IRIKit
import RDFCore
import RDFKit

extension Literal {
    /// The literal a document writes as `"lexicalForm"^^<datatype>`.
    ///
    /// `xsd:string` is the datatype of a simple literal, so it decodes to the
    /// same value as a literal written without a datatype. A language-tagged
    /// string carries its datatype through its language tag, so
    /// `rdf:langString` and `rdf:dirLangString` cannot be written with `^^`
    /// (RDF 1.2 Concepts §3.3) and this returns `nil` for them.
    static func typed(_ lexicalForm: String, datatype: IRI) -> Literal? {
        if datatype == XSD.string.metadata.id {
            return try? Literal(lexicalForm)
        }
        if datatype == RDF.langString.metadata.id || datatype == RDF.dirLangString.metadata.id {
            return nil
        }
        return try? Literal(lexicalForm, datatype: datatype)
    }
}
