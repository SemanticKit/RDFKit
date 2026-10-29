import IRIKit
import RDFCore
import RDFFormats
import Testing

@Suite("N-Triples decoder and encoder", .tags(.nTriples, .boundary))
struct NTriplesDecoderTests {
    @Test("A triple term decodes in object position and encodes canonically")
    func tripleTermRoundTrip() throws {
        let document = "_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<(<http://example/s><http://example/p>\"v\"@en--ltr)>>.\n"
        let graph = try NTriplesDecoder().decode(document)
        let term = Graph.Element(
            subject: .iri("http://example/s"),
            predicate: "http://example/p",
            object: .literal(try Literal("v", languageTag: "en", baseDirection: .ltr))
        )
        #expect(graph == [
            Graph.Element(subject: .blankNode(try BlankNode("r")), predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies", object: .tripleTerm(term))
        ])
        #expect(NTriplesEncoder().encode(graph) == """
            _:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s> <http://example/p> "v"@en--ltr )>> .

            """)
    }

    @Test("A relative IRI is a syntax error at its position")
    func relativeIRI() {
        #expect(throws: SyntaxError(line: 1, column: 1, message: "<s> is not an absolute IRI")) {
            try NTriplesDecoder().decode("<s> <http://example/p> <http://example/o> .")
        }
    }
}
