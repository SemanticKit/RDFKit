import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDGMonthDayTests {
    /// xsd:gMonthDay's value has ·month·, ·day· and ·timezoneOffset·
    /// (§3.3.12); with no year, February has 29 days.
    @Test func mapsALexicalForm() throws {
        let leapDay = try XSD.gMonthDay(lexicalForm: "--02-29")
        #expect(leapDay.value.month == 2 && leapDay.value.day == 29)
        #expect(leapDay.value.year == nil)
        #expect(leapDay.canonicalLexicalForm == "--02-29")
        #expect((leapDay as Any) is RDFS.Literal)
    }

    @Test(arguments: ["--02-30", "--04-31", "--13-01", "02-28", "--02-28T"])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.gMonthDay(lexicalForm: lexicalForm) }
    }
}
