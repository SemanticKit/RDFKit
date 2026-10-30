import IRIKit
import RDFCore
import RDFFormats
import Testing

@Suite("RDFXMLEncoder", .tags(.rdfXML, .boundary))
struct RDFXMLEncoderTests {
    /// Each kind of object has its property element form (RDF 1.2 XML
    /// Syntax §2): `rdf:resource`, `rdf:nodeID`, text with `xml:lang`,
    /// `its:dir` or `rdf:datatype`, and `rdf:parseType="Triple"`.
    @Test func writesEveryKindOfObject() throws {
        let graph = try TurtleDecoder().decode("""
            @prefix ex: <http://example.org/#> .
            ex:alice a ex:Person ;
                ex:name "Alice"@en, "<Alice & co>" ;
                ex:age 42 ;
                ex:motto "שלום"@he--rtl ;
                ex:address [ ex:city "Oslo" ] ;
                ex:said <<( ex:bob ex:knows _:c )>> .
            """)
        let document = try RDFXMLEncoder().encode(graph)
        #expect(document.contains(#"<rdf:Description rdf:about="http://example.org/#alice">"#))
        #expect(document.contains(#"<rdf:type rdf:resource="http://example.org/#Person"/>"#))
        #expect(document.contains(#"<ns1:name xml:lang="en">Alice</ns1:name>"#))
        #expect(document.contains("<ns1:name>&lt;Alice &amp; co&gt;</ns1:name>"))
        #expect(document.contains(#"<ns1:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">42</ns1:age>"#))
        #expect(document.contains(#"its:dir="rtl""#))
        #expect(document.contains(#"rdf:version="1.2""#))
        #expect(document.contains(#"rdf:parseType="Triple""#))
        #expect(try RDFXMLDecoder().decode(document).isIsomorphic(to: graph), "\(document)")
    }

    /// A predicate that does not end in an XML name cannot be an element.
    @Test func rejectsPredicatesThatAreNotXMLNames() throws {
        let graph = try NTriplesDecoder().decode("<http://example.org/s> <http://example.org/1> \"o\" .\n")
        #expect(throws: EncodingError.self) { try RDFXMLEncoder().encode(graph) }
    }
}
