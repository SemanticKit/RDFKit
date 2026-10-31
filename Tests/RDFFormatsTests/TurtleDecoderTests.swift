import IRIKit
import RDFCore
import RDFFormats
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

    @Test("Canonically equivalent prefix and blank node labels stay distinct")
    func canonicallyEquivalentLabels() throws {
        let graph = try TurtleDecoder().decode("""
            PREFIX \u{E9}: <http://a/>
            PREFIX e\u{301}: <http://b/>
            \u{E9}:s \u{E9}:p _:\u{E9} .
            e\u{301}:s e\u{301}:p _:e\u{301} .
            """)
        #expect(graph == [
            Graph.Element(subject: .iri("http://a/s"), predicate: "http://a/p", object: .blankNode(try BlankNode("\u{E9}"))),
            Graph.Element(subject: .iri("http://b/s"), predicate: "http://b/p", object: .blankNode(try BlankNode("e\u{301}"))),
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
            .literal(Literal("1", datatype: "http://www.w3.org/2001/XMLSchema#integer")),
            .literal(Literal("1.5", datatype: "http://www.w3.org/2001/XMLSchema#decimal")),
            .literal(Literal("1e5", datatype: "http://www.w3.org/2001/XMLSchema#double")),
            .literal(Literal("true", datatype: "http://www.w3.org/2001/XMLSchema#boolean")),
            .literal(Literal("x")),
        ])
    }

    @Test("An undeclared prefix is a syntax error at its position")
    func undeclaredPrefix() {
        #expect(throws: SyntaxError(line: 2, column: 1, message: "prefix 'ex:' is not declared")) {
            try TurtleDecoder().decode("PREFIX : <http://example/>\nex:s :p :o .")
        }
    }

    @Test("Keywords in quotation marks are case-insensitive; keywords in apostrophes are not", arguments: ["PREFIX", "prefix", "PrEfIx"])
    func keywordCase(keyword: String) throws {
        let graph = try TurtleDecoder().decode("\(keyword) ex: <http://example/>\nex:s ex:p ex:o .")
        #expect(graph == [Graph.Element(subject: .iri("http://example/s"), predicate: "http://example/p", object: .iri("http://example/o"))])
        #expect(throws: SyntaxError.self) {
            try TurtleDecoder().decode("@PREFIX ex: <http://example/> .")
        }
    }

    @Test("Numeric, string and reserved character escapes stand for their characters")
    func escapes() throws {
        // The document holds the backslash of each escape.
        let escape = #"\"#
        let graph = try TurtleDecoder().decode("""
            PREFIX ex: <http://example/>
            <http://example/\(escape)u0073> ex:p "a\(escape)tb\(escape)U0001F600", ex:l\(escape).x .
            """)
        #expect(Set(graph.map(\.object)) == [.literal(Literal("a\tb\u{1F600}")), .iri("http://example/l.x")])
        #expect(graph.allSatisfy { $0.subject == .iri("http://example/s") })
    }

    @Test("A numeric escape that names no Unicode scalar value is an error at the escape")
    func surrogateEscape() {
        let escape = #"\"#
        #expect(throws: SyntaxError(line: 1, column: 41, message: "escape \(escape)uD800 names no Unicode scalar value")) {
            try TurtleDecoder().decode("<http://example/s> <http://example/p> \"a\(escape)uD800\" .")
        }
    }

    @Test("A document the grammar does not match is an error where it stops matching")
    func grammarError() {
        do {
            _ = try TurtleDecoder().decode("<http://example/s>\n  <http://example/p> .")
            Issue.record("expected an error")
        } catch let error as SyntaxError {
            #expect((error.line, error.column) == (2, 22))
        } catch {
            Issue.record("unexpected \(error)")
        }
    }

    @Test("The longest match is chosen: a name before a dot, and a decimal after one")
    func longestMatch() throws {
        let graph = try TurtleDecoder().decode("PREFIX : <http://example/>\n:s :p :o.\n:s :p .5 .")
        #expect(Set(graph.map(\.object)) == [
            .iri("http://example/o"),
            .literal(Literal(".5", datatype: "http://www.w3.org/2001/XMLSchema#decimal")),
        ])
    }
}
