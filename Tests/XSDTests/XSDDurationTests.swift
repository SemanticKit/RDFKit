import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDurationTests {
    /// xsd:duration's value is a number of months and a number of seconds
    /// (XSD 1.1 Part 2 §3.3.6), which ·durationMap· gives a lexical form
    /// (§E.2), and it is a literal.
    @Test func mapsALexicalFormToMonthsAndSeconds() throws {
        let term = try XSD.duration(lexicalForm: "P1Y2M")
        #expect(term.value.months == DecimalNumber(14))
        #expect(term.value.seconds == DecimalNumber(0))
        #expect((term as Any) is RDFS.Literal)

        let negative = try XSD.duration(lexicalForm: "-P3DT4H")
        #expect(negative.value.months == DecimalNumber(0))
        #expect(negative.value.seconds == -DecimalNumber(3 * 86_400 + 4 * 3_600))
    }

    /// Equality is of months and of seconds (§3.3.6.2): P1Y is P12M, and
    /// P1D is PT24H, but P1M is not P30D.
    @Test func equalityIsOfMonthsAndSeconds() throws {
        #expect(try XSD.duration(lexicalForm: "P1Y") == XSD.duration(lexicalForm: "P12M"))
        #expect(try XSD.duration(lexicalForm: "P1D") == XSD.duration(lexicalForm: "PT24H"))
        #expect(try XSD.duration(lexicalForm: "P1M") != XSD.duration(lexicalForm: "P30D"))
    }

    /// ·durationCanonicalMap· (§E.2) writes the value back.
    @Test func hasACanonicalLexicalForm() throws {
        #expect(try XSD.duration(lexicalForm: "P12M").lexicalForm == "P1Y")
        #expect(try XSD.duration(lexicalForm: "-PT28H").lexicalForm == "-P1DT4H")
        #expect(try XSD.duration(lexicalForm: "PT1.50S").lexicalForm == "PT1.5S")
        #expect(try XSD.duration(lexicalForm: "P0D").lexicalForm == "PT0S")
    }

    /// A form outside the lexical space has no value: the literal is
    /// ill-typed (RDF 1.2 Concepts §3.4).
    @Test(arguments: ["", "P", "PT", "1Y", "P1D2Y", "P1.5Y", "P1YT", "+P1Y", "P-1Y", "P1H", " P1Y", "PT1M2H"])
    func rejectsAFormOutsideTheLexicalSpace(_ form: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.duration(lexicalForm: form) }
    }
}
