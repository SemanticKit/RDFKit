import RDFCore
import RDFFormats
import Testing

/// Literal term equality (RDF 1.2 Concepts §3.4), read from documents: two
/// literals a document states are one triple's object when they are the
/// same term, and a graph keeps the literals it holds through an encoding.
@Suite("Literal", .tags(.term))
struct LiteralTests {
    @Test("Language tags compare case-insensitively")
    func languageTagCase() throws {
        let graph = try Graph(fixture: "language-tag-case.ttl")
        #expect(graph.count == 1)
        #expect(graph.literals.map(\.languageTag) == ["fr-ca"])
        #expect(try graph.roundTripped() == graph)
    }

    @Test("The base direction is part of the term")
    func baseDirection() throws {
        let graph = try Graph(fixture: "base-direction.ttl")
        #expect(graph.count == 3)
        #expect(graph.literals.map(\.baseDirection) == [.ltr, .rtl, nil])
        #expect(graph.literals.first?.description == #""chat"@fr--ltr"#)
        #expect(try graph.roundTripped() == graph)
    }

    @Test("Lexical forms compare Unicode scalar by Unicode scalar, not by canonical equivalence")
    func lexicalFormScalars() throws {
        let graph = try Graph(fixture: "lexical-forms.ttl")
        // "é"@fr and "é"@FR are one term.
        #expect(graph.count == 4)
        let literals = graph.literals
        let (composed, decomposed) = (literals[0], literals[1])
        #expect(composed != decomposed)
        #expect(Set([composed, decomposed]).count == 2)
        #expect(decomposed < composed)
        #expect(!(composed < decomposed))
        #expect(!(composed < composed))
        #expect(literals[2] != literals[3])
        #expect(literals[2].lexicalForm.unicodeScalars.elementsEqual(composed.lexicalForm.unicodeScalars))
        #expect(try graph.roundTripped() == graph)
    }

    @Test("A literal typed xsd:string is the simple literal")
    func xsdString() throws {
        let graph = try Graph(fixture: "xsd-string.ttl")
        #expect(graph.count == 1)
        #expect(graph.literals.map(\.datatype) == [nil])
        #expect(try graph.roundTripped() == graph)
    }

    @Test("rdf:langString and rdf:dirLangString need a language tag", arguments: ["lang-string-datatype.ttl", "dir-lang-string-datatype.ttl"])
    func languageStringDatatypes(_ fixture: String) {
        #expect(throws: (any Error).self) {
            try Graph(fixture: fixture)
        }
    }

    @Test("Well-formed BCP 47 tags are accepted, and kept in lower case")
    func wellFormedLanguageTags() throws {
        // Each literal's lexical form is its tag as the document writes it.
        let graph = try Graph(fixture: "language-tags-well-formed.nt")
        #expect(graph.count == 12)
        for literal in graph.literals {
            #expect(literal.languageTag == literal.lexicalForm.lowercased())
        }
        #expect(try graph.roundTripped() == graph)
    }

    @Test("A language tag must be well-formed BCP 47")
    func malformedLanguageTags() throws {
        // Each line is a document whose one tag is not well-formed.
        let documents = try String(fixture: "language-tags-malformed.nt").split(separator: "\n")
        #expect(documents.count == 6)
        for document in documents {
            #expect(throws: (any Error).self, "\(document)") {
                try NTriplesDecoder().decode(String(document))
            }
        }
    }

    @Test("Typed literals compare lexical form and datatype IRI")
    func typedEquality() throws {
        let graph = try Graph(fixture: "typed-literals.ttl")
        // "1"^^xsd:integer twice is one term; "01", "1"^^xsd:decimal and
        // the simple "1" are three others.
        #expect(graph.count == 4)
        #expect(Set(graph.literals).count == 4)
        #expect(graph.literals.allSatisfy { $0.datatype != nil } == false)
        #expect(try graph.roundTripped() == graph)
    }
}
