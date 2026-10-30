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
    }

    @Test("The base direction is part of the term")
    func baseDirection() throws {
        let graph = try Fixture.graph("base-direction.nt")
        #expect(graph.count == 3)
        #expect(Set(graph.literals.map(\.baseDirection)) == [.ltr, .rtl, nil])
        #expect(graph.literals.first?.description == #""chat"@fr--ltr"#)
    }

    @Test("A literal typed xsd:string is the simple literal")
    func xsdString() throws {
        let graph = try Fixture.graph("xsd-string.nt")
        #expect(graph.count == 1)
        #expect(graph.literals.first?.datatype == nil)
    }

    @Test("rdf:langString and rdf:dirLangString need a language tag", arguments: ["lang-string-without-tag.nt", "dir-lang-string-without-tag.nt"])
    func languageStringDatatypes(_ name: String) throws {
        let document = try Fixture.text(name)
        #expect(throws: (any Error).self) {
            try NTriplesDecoder().decode(document)
        }
    }

    @Test("Every literal has the datatype IRI RDF 1.2 gives it")
    func datatypeIRI() throws {
        let graph = try Fixture.graph("datatypes.nt")
        let subjects = Set(graph.map(\.subject))
        #expect(subjects.count == 4)
        for subject in subjects {
            let values = graph.triples(subject: subject).literals
            let datatypes: [ObjectTerm] = graph.triples(subject: subject).compactMap { triple in
                if case .literal = triple.object { nil } else { triple.object }
            }
            #expect(values.count == 1)
            #expect(datatypes == values.map { .iri($0.datatypeIRI) }, "\(subject)")
        }
    }

    @Test("Typed literals compare lexical form and datatype IRI")
    func typedEquality() throws {
        let graph = try Fixture.graph("typed-literals.nt")
        // "1"^^xsd:integer once, "01"^^xsd:integer, "1"^^xsd:decimal and "1".
        #expect(graph.count == 4)
        #expect(Set(graph.literals).count == 4)
    }
}
