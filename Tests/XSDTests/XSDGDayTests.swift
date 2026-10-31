import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDGDayTests {
    /// xsd:gDay's value has only ·day· and ·timezoneOffset· (§3.3.13).
    @Test func mapsALexicalForm() throws {
        let day = try XSD.gDay(lexicalForm: "---31+02:00")
        #expect(day.value.day == 31)
        #expect(day.value.month == nil && day.value.year == nil)
        #expect(day.value.timezoneOffset == 120)
        #expect(day.canonicalLexicalForm == "---31+02:00")
        #expect((day as Any) is RDFS.Literal)
    }

    @Test(arguments: ["---32", "---00", "--31", "---1"])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.gDay(lexicalForm: lexicalForm) }
    }
}
