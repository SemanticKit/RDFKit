import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDGYearTests {
    /// xsd:gYear's value has only ·year· and ·timezoneOffset· (§3.3.11).
    @Test func mapsALexicalForm() throws {
        let year = try XSD.gYear(lexicalForm: "2026Z")
        #expect(year.value.year == BigInteger(2026))
        #expect(year.value.month == nil && year.value.day == nil)
        #expect(year.canonicalLexicalForm == "2026Z")
        #expect(try XSD.gYear(lexicalForm: "12026").value.year == BigInteger(12_026))
        #expect(try XSD.gYear(lexicalForm: "-0001").canonicalLexicalForm == "-0001")
        #expect((year as Any) is RDFS.Literal)
    }

    @Test(arguments: ["26", "02026", "2026-10", "+2026"])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.gYear(lexicalForm: lexicalForm) }
    }
}
