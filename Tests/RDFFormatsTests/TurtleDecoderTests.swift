import IRIKit
import RDFCore
import RDFFormats
import RDFKit
import Testing

@Suite("Turtle decoder", .tags(.turtle, .boundary))
struct TurtleDecoderTests {
    let rdfReifies: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies"

    @Test("An annotation asserts the triple and reifies it as a triple term")
    func annotationReifiesTripleTerm() throws {
        let graph = try TurtleDecoder().decode("""
            PREFIX : <http://example/>
            :s :p :o ~ :r {| :source :q |} .
            """)
        let asserted = Graph.Element(subject: .iri("http://example/s"), predicate: "http://example/p", object: .iri("http://example/o"))
        let term = Graph.Element(subject: .iri("http://example/s"), predicate: "http://example/p", object: .iri("http://example/o"))
        #expect(graph == [
            asserted,
            Graph.Element(subject: .iri("http://example/r"), predicate: rdfReifies, object: .tripleTerm(term)),
            Graph.Element(subject: .iri("http://example/r"), predicate: "http://example/source", object: .iri("http://example/q")),
        ])
    }

    @Test("A base direction decodes into the literal's base direction")
    func baseDirection() throws {
        let graph = try TurtleDecoder().decode(#"<http://example/s> <http://example/p> "שלום"@HE--rtl ."#)
        guard case .literal(let literal) = try #require(graph.first).object else {
            Issue.record("expected a literal")
            return
        }
        #expect(literal.lexicalForm == "שלום")
        #expect(literal.languageTag == "he")
        #expect(literal.baseDirection == .rtl)
        #expect(literal.datatype == nil)
    }

    @Test("Relative references resolve against the base IRI")
    func relativeReferences() throws {
        let graph = try TurtleDecoder(base: "http://example/a/b").decode("<../c> <#p> <d?q> .")
        #expect(graph == [
            Graph.Element(subject: .iri("http://example/c"), predicate: "http://example/a/b#p", object: .iri("http://example/a/d?q"))
        ])
    }

    @Test("Numbers and booleans take their XSD datatypes, and xsd:string is a simple literal")
    func literalDatatypes() throws {
        let graph = try TurtleDecoder().decode("""
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
            <http://example/s> <http://example/p> 1, 1.5, 1e5, true, "x"^^xsd:string .
            """)
        #expect(Set(graph.map(\.object)) == [
            .literal(try Literal("1", datatype: "http://www.w3.org/2001/XMLSchema#integer")),
            .literal(try Literal("1.5", datatype: "http://www.w3.org/2001/XMLSchema#decimal")),
            .literal(try Literal("1e5", datatype: "http://www.w3.org/2001/XMLSchema#double")),
            .literal(try Literal("true", datatype: "http://www.w3.org/2001/XMLSchema#boolean")),
            .literal(Literal("x")),
        ])
    }

    @Test("An undeclared prefix is a syntax error at its position")
    func undeclaredPrefix() {
        #expect(throws: SyntaxError(line: 2, column: 1, message: "prefix 'ex:' is not declared")) {
            try TurtleDecoder().decode("PREFIX : <http://example/>\nex:s :p :o .")
        }
    }
}
