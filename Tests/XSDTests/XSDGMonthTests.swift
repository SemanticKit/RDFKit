import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDGMonthTests {
    /// xsd:gMonth's value has only ·month· and ·timezoneOffset· (§3.3.14).
    @Test func mapsALexicalForm() throws {
        let october = try XSD.gMonth(lexicalForm: "--10")
        #expect(october.value.month == 10)
        #expect(october.value.year == nil && october.value.day == nil)
        #expect(october.canonicalLexicalForm == "--10")
        #expect(try XSD.gMonth(lexicalForm: "--10-14:00").value.timezoneOffset == -840)
        #expect((october as Any) is RDFS.Literal)
    }

    @Test(arguments: ["--13", "--00", "10", "--10--"])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.gMonth(lexicalForm: lexicalForm) }
    }
}
