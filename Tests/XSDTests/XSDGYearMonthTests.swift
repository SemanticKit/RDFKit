import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDGYearMonthTests {
    /// xsd:gYearMonth's value has ·year·, ·month· and ·timezoneOffset·
    /// (§3.3.10).
    @Test func mapsALexicalForm() throws {
        let month = try XSD.gYearMonth(lexicalForm: "2026-10")
        #expect(month.value.year == BigInteger(2026) && month.value.month == 10)
        #expect(month.value.day == nil)
        #expect(month.canonicalLexicalForm == "2026-10")
        #expect((month as Any) is RDFS.Literal)
    }

    @Test(arguments: ["2026-13", "2026-1", "2026-10-30", "2026"])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.gYearMonth(lexicalForm: lexicalForm) }
    }
}
