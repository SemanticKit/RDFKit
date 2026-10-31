import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDayTimeDurationTests {
    /// xsd:dayTimeDuration is derived from xsd:duration by the pattern
    /// `[^YM]*(T.*)?` (XSD 1.1 Part 2 §3.4.27): its values have no months.
    @Test func isADurationOfDaysAndTime() throws {
        let term = try XSD.dayTimeDuration(lexicalForm: "-P3DT4H")
        #expect(term.value.months == DecimalNumber(0))
        #expect(term.value.seconds == -DecimalNumber(3 * 86_400 + 4 * 3_600))
        #expect(try term.value == XSD.duration(lexicalForm: "-P3DT4H").value)
        #expect(term.lexicalForm == "-P3DT4H")
        #expect((term as Any) is RDFS.Literal)
    }

    /// A duration with months is not in its value space, nor is a form
    /// with years or months in its lexical space.
    @Test func excludesYearsAndMonths() throws {
        #expect(throws: DatatypeError.illTyped) { try XSD.dayTimeDuration(lexicalForm: "P1Y") }
        #expect(throws: DatatypeError.illTyped) { try XSD.dayTimeDuration(lexicalForm: "P1MT2H") }
        #expect(throws: DatatypeError.illTyped) { try XSD.dayTimeDuration(XSD.duration(lexicalForm: "P1M").value) }
        #expect(try XSD.dayTimeDuration(XSD.duration(lexicalForm: "PT36H").value).lexicalForm == "P1DT12H")
        #expect(try XSD.dayTimeDuration(lexicalForm: "PT2M").value.seconds == DecimalNumber(120))
    }

    /// A form its pattern allows that is not a duration is ill-typed too.
    @Test(arguments: ["P", "PT", "P1D2H", "3D"])
    func rejectsAFormThatIsNoDuration(_ form: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.dayTimeDuration(lexicalForm: form) }
    }
}
