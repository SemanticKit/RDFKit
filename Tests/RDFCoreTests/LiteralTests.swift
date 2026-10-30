import IRIKit
import RDFCore
import Testing

@Suite("Literal", .tags(.term))
struct LiteralTests {
    /// Datatype IRIs, as a document writes them.
    static let xsdString: IRI = "http://www.w3.org/2001/XMLSchema#string"
    static let xsdInteger: IRI = "http://www.w3.org/2001/XMLSchema#integer"
    static let xsdDecimal: IRI = "http://www.w3.org/2001/XMLSchema#decimal"
    static let rdfLangString: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"
    static let rdfDirLangString: IRI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString"

    @Test("Language tags compare case-insensitively")
    func languageTagCase() throws {
        let upper = try Literal("chat", languageTag: "FR-ca")
        let lower = try Literal("chat", languageTag: "fr-CA")
        #expect(upper == lower)
        #expect(upper.hashValue == lower.hashValue)
        #expect(upper.languageTag == "fr-ca")
    }

    @Test("The base direction is part of the term")
    func baseDirection() throws {
        let ltr = try Literal("chat", languageTag: "fr", baseDirection: .ltr)
        let rtl = try Literal("chat", languageTag: "fr", baseDirection: .rtl)
        let none = try Literal("chat", languageTag: "fr")
        #expect(Set([ltr, rtl, none]).count == 3)
        #expect(ltr.description == #""chat"@fr--ltr"#)
    }

    @Test("Lexical forms compare Unicode scalar by Unicode scalar, not by canonical equivalence")
    func lexicalFormScalars() throws {
        let composed = Literal("\u{E9}")
        let decomposed = Literal("e\u{301}")
        #expect(composed != decomposed)
        #expect(Set([composed, decomposed]).count == 2)
        #expect(decomposed < composed)
        #expect(!(composed < decomposed))
        #expect(!(composed < Literal("\u{E9}")))
        let tagged = try Literal("\u{E9}", languageTag: "fr")
        #expect(tagged != (try Literal("e\u{301}", languageTag: "fr")))
        #expect(tagged == (try Literal("\u{E9}", languageTag: "FR")))
    }

    @Test("A language tag cannot be empty")
    func emptyLanguageTag() {
        #expect(throws: TermError.emptyLanguageTag) {
            try Literal("chat", languageTag: "")
        }
    }

    @Test("A language tag must be well-formed BCP 47", arguments: ["en us", "en-", "-en", "en--us", "--", "e", "en-a", "abcdefghi", "en-x", "x", "en-ÿ", "a-en"])
    func malformedLanguageTag(_ tag: String) {
        #expect(throws: TermError.malformedLanguageTag) {
            try Literal("chat", languageTag: tag)
        }
    }

    @Test("Well-formed BCP 47 tags are accepted", arguments: ["en", "en-US", "zh-Hant-TW", "sr-Latn-RS", "es-419", "de-CH-1996", "zh-yue-HK", "en-a-bbb-x-a-ccc", "x-whatever", "i-klingon", "art-lojban", "ABCDEFGH"])
    func wellFormedLanguageTag(_ tag: String) throws {
        let literal = try Literal("chat", languageTag: tag)
        #expect(literal.languageTag == tag.lowercased())
    }

    @Test("A literal typed xsd:string is the simple literal")
    func xsdString() throws {
        let typed = try Literal("a", datatype: Self.xsdString)
        #expect(typed == Literal("a"))
        #expect(typed.datatype == nil)
    }

    @Test("rdf:langString and rdf:dirLangString need a language tag", arguments: [LiteralTests.rdfLangString, LiteralTests.rdfDirLangString])
    func languageStringDatatypes(_ datatype: IRI) {
        #expect(throws: TermError.datatypeRequiresLanguageTag) {
            try Literal("a", datatype: datatype)
        }
    }

    @Test("Every literal has the datatype IRI RDF 1.2 gives it")
    func datatypeIRI() throws {
        #expect(Literal("a").datatypeIRI == Self.xsdString)
        #expect(try Literal("a", languageTag: "en").datatypeIRI == Self.rdfLangString)
        #expect(try Literal("a", languageTag: "en", baseDirection: .rtl).datatypeIRI == Self.rdfDirLangString)
        #expect(try Literal("1", datatype: Self.xsdInteger).datatypeIRI == Self.xsdInteger)
    }

    @Test("Typed literals compare lexical form and datatype IRI")
    func typedEquality() throws {
        let one = try Literal("1", datatype: Self.xsdInteger)
        #expect(one == (try Literal("1", datatype: Self.xsdInteger)))
        #expect(one != (try Literal("01", datatype: Self.xsdInteger)))
        #expect(one != (try Literal("1", datatype: Self.xsdDecimal)))
        #expect(one != Literal("1"))
    }
}
