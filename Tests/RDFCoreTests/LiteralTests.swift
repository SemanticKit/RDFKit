import IRIKit
import RDFCore
import RDFKit
import Testing

@Suite("Literal", .tags(.term))
struct LiteralTests {
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

    @Test("A language tag cannot be empty")
    func emptyLanguageTag() {
        #expect(throws: TermError.emptyLanguageTag) {
            try Literal("chat", languageTag: "")
        }
    }

    @Test("A literal typed xsd:string is the simple literal")
    func xsdString() throws {
        let typed = try Literal("a", datatype: XSD.string.metadata.id)
        #expect(typed == Literal("a"))
        #expect(typed.datatype == nil)
    }

    @Test("rdf:langString and rdf:dirLangString need a language tag", arguments: [RDF.langString.metadata.id, RDF.dirLangString.metadata.id])
    func languageStringDatatypes(_ datatype: IRI) {
        #expect(throws: TermError.datatypeRequiresLanguageTag) {
            try Literal("a", datatype: datatype)
        }
    }

    @Test("Typed literals compare lexical form and datatype IRI")
    func typedEquality() throws {
        let one = try Literal("1", datatype: XSD.integer.metadata.id)
        #expect(one == (try Literal("1", datatype: XSD.integer.metadata.id)))
        #expect(one != (try Literal("01", datatype: XSD.integer.metadata.id)))
        #expect(one != (try Literal("1", datatype: XSD.decimal.metadata.id)))
        #expect(one != Literal("1"))
    }
}
