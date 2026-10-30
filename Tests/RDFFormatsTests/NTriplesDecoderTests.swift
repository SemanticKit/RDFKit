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

    @Test("Canonically equivalent literals and labels stay distinct terms and round-trip byte for byte")
    func canonicallyEquivalentTerms() throws {
        let document = """
            <http://e/s> <http://e/p> "\u{E9}" .
            <http://e/s> <http://e/p> "e\u{301}" .
            _:\u{E9} <http://e/p> <http://e/o> .
            _:e\u{301} <http://e/p> <http://e/o> .

            """
        let graph = try NTriplesDecoder().decode(document)
        #expect(graph.count == 4)
        #expect(Array(NTriplesEncoder().encode(graph).utf8) == Array(document.utf8))
    }

    @Test("A relative IRI is a syntax error at its position")
    func relativeIRI() {
        #expect(throws: SyntaxError(line: 1, column: 1, message: "<s> is not an absolute IRI")) {
            try NTriplesDecoder().decode("<s> <http://example/p> <http://example/o> .")
        }
    }

    @Test("A malformed language tag is a syntax error at the '@'")
    func malformedLanguageTag() {
        #expect(throws: SyntaxError(line: 1, column: 42, message: "'en-a' is not a well-formed BCP 47 language tag")) {
            try NTriplesDecoder().decode("<http://example/s> <http://example/p> \"o\"@en-a .")
        }
    }

    @Test("Language-tagged literals encode and decode to the same graph")
    func languageTagRoundTrip() throws {
        let graph: Graph = [
            Graph.Element(subject: .iri("http://example/s"), predicate: "http://example/p", object: .literal(try Literal("o", languageTag: "sr-Latn-RS", baseDirection: .rtl))),
            Graph.Element(subject: .iri("http://example/s"), predicate: "http://example/p", object: .literal(try Literal("o", languageTag: "x-private")))
        ]
        #expect(try NTriplesDecoder().decode(NTriplesEncoder().encode(graph)) == graph)
    }

    @Test("Blank node identifiers that are not N-Triples labels encode under fresh labels")
    func blankNodeRelabelling() throws {
        let foreign = try BlankNode("nodeID://b1")
        let other = try BlankNode("node id 2")
        let b0 = try BlankNode("b0")
        let inner = Graph.Element(subject: .blankNode(other), predicate: "http://example/p", object: .blankNode(foreign))
        let graph: Graph = [
            Graph.Element(subject: .blankNode(foreign), predicate: "http://example/p", object: .literal(Literal("o"))),
            Graph.Element(subject: .blankNode(b0), predicate: "http://example/p", object: .blankNode(foreign)),
            Graph.Element(subject: .blankNode(other), predicate: "http://example/q", object: .tripleTerm(inner))
        ]
        let document = NTriplesEncoder().encode(graph)
        #expect(document == """
            _:b1 <http://example/p> "o" .
            _:b0 <http://example/p> _:b1 .
            _:b2 <http://example/q> <<( _:b2 <http://example/p> _:b1 )>> .

            """)
        let decoded = try NTriplesDecoder().decode(document)
        #expect(decoded.isIsomorphic(to: graph))
    }
}
