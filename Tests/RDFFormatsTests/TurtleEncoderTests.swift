import IRIKit
import RDFCore
import RDFFormats
import Testing

@Suite("TurtleEncoder", .tags(.turtle, .boundary))
struct TurtleEncoderTests {
    static let document = """
        @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
        @prefix ex: <http://example.org/#> .
        ex:alice a ex:Person ;
            ex:name "Alice"@en, "Alicia"@es ;
            ex:age 42 ;
            ex:height 1.68 ;
            ex:member true ;
            ex:address [ ex:city "Oslo" ] ;
            ex:friends ( ex:bob ex:carol ) ;
            ex:said <<( ex:bob ex:knows ex:carol )>> .
        ex:bob ex:knows ex:carol .
        """

    /// RDF 1.2 Turtle §2: prefixed names, `a`, `;` and `,`, `[ … ]`,
    /// `( … )` and the short forms of numbers and booleans.
    @Test func writesTheAbbreviations() throws {
        let graph = try TurtleDecoder().decode(Self.document)
        let document = TurtleEncoder(prefixes: [Prefix("ex", "http://example.org/#")]).encode(graph)
        #expect(document.hasPrefix("PREFIX ex: <http://example.org/#>\n"))
        #expect(document.contains("ex:alice a ex:Person ;"))
        #expect(document.contains("ex:name \"Alice\"@en, \"Alicia\"@es ;"))
        #expect(document.contains("ex:age 42 ;"))
        #expect(document.contains("ex:height 1.68 ;"))
        #expect(document.contains("ex:member true ;"))
        #expect(document.contains("ex:address [\n"))
        #expect(document.contains("ex:friends ( ex:bob ex:carol ) ;"))
        #expect(document.contains("ex:said <<( ex:bob ex:knows ex:carol )>> ."))
        #expect(!document.contains("_:"))
        #expect(try TurtleDecoder().decode(document).isIsomorphic(to: graph), "\(document)")
    }

    /// A namespace without a given prefix gets one of its own.
    @Test func declaresAPrefixForEveryNamespace() throws {
        let graph = try TurtleDecoder().decode("<http://example.org/a#s> <http://example.org/b#p> <http://example.org/a#o> .")
        let document = TurtleEncoder().encode(graph)
        #expect(document == "PREFIX ns1: <http://example.org/a#>\nPREFIX ns2: <http://example.org/b#>\n\nns1:s ns2:p ns1:o .\n")
    }

    /// Blank nodes that are the object of more than one triple, or that
    /// reach each other in a cycle, keep their labels.
    @Test func labelsSharedAndCyclicBlankNodes() throws {
        let graph = try TurtleDecoder().decode("""
            @prefix ex: <http://example.org/#> .
            ex:a ex:p _:shared . ex:b ex:p _:shared .
            _:x ex:next _:y . _:y ex:next _:x .
            """)
        let document = TurtleEncoder().encode(graph)
        #expect(document.contains("_:shared"))
        #expect(try TurtleDecoder().decode(document).isIsomorphic(to: graph), "\(document)")
    }

    /// Literals that are not in a short form keep their datatype; IRIs
    /// whose local name is not a `PN_LOCAL` are written whole.
    @Test func writesOtherLiteralsAndIRIsInFull() throws {
        let graph = try TurtleDecoder().decode(#"""
            <http://example.org/#s> <http://example.org/#p> "01"^^<http://www.w3.org/2001/XMLSchema#boolean>, "a\nb\"c", "x"@en--rtl, <http://example.org/#a.> .
            """#)
        let document = TurtleEncoder().encode(graph)
        #expect(document.contains(#""01"^^ns2:boolean"#))
        #expect(document.contains(#""a\nb\"c""#))
        #expect(document.contains(#""x"@en--rtl"#))
        #expect(document.contains("<http://example.org/#a.>"))
        #expect(try TurtleDecoder().decode(document) == graph, "\(document)")
    }
}
