import IRIKit
import RDFCore
import RDFFormats
import Testing

/// Literal term equality (RDF 1.2 Concepts §3.4), checked on literals
/// decoded from N-Triples fixtures.
@Suite("Literal", .tags(.term))
struct LiteralTests {
    @Test("Language tags compare case-insensitively")
    func languageTagCase() throws {
        let graph = try Fixture.graph("language-tag-case.nt")
        #expect(graph.count == 1)
        #expect(graph.literals.map(\.languageTag) == ["fr-ca"])
        #expect(try graph.roundTripped() == graph)
    }

    @Test("The base direction is part of the term")
    func baseDirection() throws {
        let graph = try Fixture.graph("base-direction.nt")
        #expect(graph.count == 3)
        #expect(Set(graph.literals.map(\.baseDirection)) == [.ltr, .rtl, nil])
        #expect(graph.literals.first?.description == #""chat"@fr--ltr"#)
        #expect(try graph.roundTripped() == graph)
    }

    @Test("Lexical forms compare Unicode scalar by Unicode scalar, not by canonical equivalence")
    func lexicalFormScalars() throws {
        let graph = try Fixture.graph("lexical-forms.nt")
        // U+00E9 and e U+0301, then the tagged forms, of which "\u{E9}"@fr
        // and "\u{E9}"@FR are one term.
        #expect(graph.count == 4)
        let literals = graph.literals
        let (composed, decomposed) = (literals[0], literals[1])
        #expect(composed != decomposed)
        #expect(Set([composed, decomposed]).count == 2)
        #expect(decomposed < composed)
        #expect(!(composed < decomposed))
        #expect(literals[2] != literals[3])
        #expect(try graph.roundTripped() == graph)
    }

    @Test("A literal typed xsd:string is the simple literal")
    func xsdString() throws {
        let graph = try Fixture.graph("xsd-string.nt")
        #expect(graph.count == 1)
        #expect(graph.literals.first?.datatype == nil)
        #expect(try graph.roundTripped() == graph)
    }

    @Test("rdf:langString and rdf:dirLangString need a language tag", arguments: ["lang-string-without-tag.nt", "dir-lang-string-without-tag.nt"])
    func languageStringDatatypes(_ name: String) throws {
        let document = try Fixture.text(name)
        #expect(throws: (any Error).self) {
            try NTriplesDecoder().decode(document)
        }
    }

    @Test("Typed literals compare lexical form and datatype IRI")
    func typedEquality() throws {
        let graph = try Fixture.graph("typed-literals.nt")
        // "1"^^xsd:integer once, "01"^^xsd:integer, "1"^^xsd:decimal and "1".
        #expect(graph.count == 4)
        #expect(Set(graph.literals).count == 4)
        #expect(try graph.roundTripped() == graph)
    }
}
