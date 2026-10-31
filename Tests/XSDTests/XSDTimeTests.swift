import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDTimeTests {
    /// xsd:time's value has only ·hour·, ·minute·, ·second· and
    /// ·timezoneOffset· (§3.3.8), by ·timeLexicalMap·.
    @Test func mapsALexicalForm() throws {
        let time = try XSD.time(lexicalForm: "12:30:00.500+05:30")
        #expect(time.value.year == nil && time.value.month == nil && time.value.day == nil)
        #expect(time.value.hour == 12 && time.value.minute == 30)
        #expect(time.value.timezoneOffset == 330)
        #expect(time.canonicalLexicalForm == "12:30:00.5+05:30")
        #expect((time as Any) is RDFS.Literal)
    }

    /// `24:00:00` is `00:00:00`.
    @Test func endOfDayIsMidnight() throws {
        #expect(try XSD.time(lexicalForm: "24:00:00") == XSD.time(lexicalForm: "00:00:00"))
        #expect(try XSD.time(lexicalForm: "24:00:00.000").canonicalLexicalForm == "00:00:00")
    }

    @Test(arguments: ["25:00:00", "12:60:00", "24:00:01", "12:00", "T12:00:00"])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.time(lexicalForm: lexicalForm) }
    }
}
