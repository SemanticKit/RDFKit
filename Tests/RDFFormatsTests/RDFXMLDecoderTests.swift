import IRIKit
import RDFCore
import RDFFormats
import Testing

@Suite("RDF/XML decoder", .tags(.rdfXML, .boundary))
struct RDFXMLDecoderTests {
    let xmlLiteral: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"

    func xmlLiteralForm(_ content: String, namespaces: String = "") throws -> String {
        let triples = try RDFXMLDecoder().decode("""
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ex="http://example/" \(namespaces)>
              <rdf:Description rdf:about="http://example/s"><ex:p rdf:parseType="Literal">\(content)</ex:p></rdf:Description>
            </rdf:RDF>
            """)
        guard case .literal(let literal) = try #require(triples.first).object else {
            Issue.record("expected a literal")
            return ""
        }
        #expect(literal.datatype == xmlLiteral)
        return literal.lexicalForm
    }

    @Test("An XML literal declares the namespaces its elements visibly use, once")
    func xmlLiteralNamespaces() throws {
        let form = try xmlLiteralForm(
            "<html:h1><b>John</b><html:i/></html:h1>",
            namespaces: #"xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://NoHTML.example.org""#
        )
        #expect(form == #"<html:h1 xmlns:html="http://NoHTML.example.org"><b xmlns="http://www.w3.org/1999/xhtml">John</b><html:i></html:i></html:h1>"#)
    }

    @Test("An XML literal orders namespace declarations by prefix and attributes by namespace and name")
    func xmlLiteralOrdering() throws {
        let form = try xmlLiteralForm(
            #"<ex:a z="1" ex:b="2" y:c="3" a="4"/>"#,
            namespaces: #"xmlns:y="http://a.example/""#
        )
        #expect(form == #"<ex:a xmlns:ex="http://example/" xmlns:y="http://a.example/" a="4" z="1" y:c="3" ex:b="2"></ex:a>"#)
    }

    @Test("An XML literal keeps comments and escapes text and attribute values")
    func xmlLiteralEscaping() throws {
        let form = try xmlLiteralForm(#"a &lt; b &amp;&#xD; c<!-- note --><ex:q v="&quot;&#x9;&lt;"/>"#)
        #expect(form == #"a &lt; b &amp;&#xD; c<!-- note --><ex:q xmlns:ex="http://example/" v="&quot;&#x9;&lt;"></ex:q>"#)
    }
}
