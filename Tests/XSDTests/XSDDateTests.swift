import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDateTests {
    /// xsd:date's value has ·year·, ·month·, ·day· and ·timezoneOffset·
    /// (§3.3.9), by ·dateLexicalMap·; year 0 is 1 BCE.
    @Test func mapsALexicalForm() throws {
        let ides = try XSD.date(lexicalForm: "-0043-03-15")
        #expect(ides.value.year == BigInteger(-43))
        #expect(ides.value.month == 3 && ides.value.day == 15)
        #expect(ides.value.hour == nil && ides.value.timezoneOffset == nil)
        #expect(ides.canonicalLexicalForm == "-0043-03-15")
        #expect(try XSD.date(lexicalForm: "2026-10-30Z").canonicalLexicalForm == "2026-10-30Z")
        #expect((ides as Any) is RDFS.Literal)
    }

    /// The day is within its month, in a leap year or not.
    @Test func checksTheDayOfTheMonth() throws {
        #expect(try XSD.date(lexicalForm: "2024-02-29").value.day == 29)
        #expect(throws: DatatypeError.illTyped) { try XSD.date(lexicalForm: "2023-02-29") }
        #expect(throws: DatatypeError.illTyped) { try XSD.date(lexicalForm: "1900-02-29") }
        #expect(throws: DatatypeError.illTyped) { try XSD.date(lexicalForm: "2026-04-31") }
        #expect(throws: DatatypeError.illTyped) { try XSD.date(lexicalForm: "2026-10-30T00:00:00") }
    }
}
