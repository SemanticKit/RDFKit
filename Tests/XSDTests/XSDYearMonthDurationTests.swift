import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDYearMonthDurationTests {
    /// xsd:yearMonthDuration is derived from xsd:duration by the pattern
    /// `[^DT]*` (XSD 1.1 Part 2 §3.4.26): its values have no seconds.
    @Test func isADurationOfYearsAndMonths() throws {
        let term = try XSD.yearMonthDuration(lexicalForm: "P1Y2M")
        #expect(term.value.months == DecimalNumber(14))
        #expect(term.value.seconds == DecimalNumber(0))
        #expect(try term.value == XSD.duration(lexicalForm: "P14M").value)
        #expect(term.lexicalForm == "P1Y2M")
        #expect((term as Any) is RDFS.Literal)
    }

    /// A duration with seconds is not in its value space, nor is a form
    /// with days or a time in its lexical space.
    @Test func excludesDaysAndTime() throws {
        #expect(throws: DatatypeError.illTyped) { try XSD.yearMonthDuration(lexicalForm: "P1D") }
        #expect(throws: DatatypeError.illTyped) { try XSD.yearMonthDuration(lexicalForm: "P1YT0S") }
        #expect(throws: DatatypeError.illTyped) { try XSD.yearMonthDuration(XSD.duration(lexicalForm: "PT1S").value) }
        #expect(try XSD.yearMonthDuration(XSD.duration(lexicalForm: "-P25M").value).lexicalForm == "-P2Y1M")
    }

    /// The zero duration is in its value space, and its canonical form here
    /// is P0M, not duration's PT0S (§3.4.26.1).
    @Test func writesZeroAsZeroMonths() throws {
        let zero = try XSD.yearMonthDuration(XSD.duration(lexicalForm: "PT0S").value)
        #expect(zero.lexicalForm == "P0M")
        #expect(try XSD.yearMonthDuration(lexicalForm: "P0Y") == zero)
    }
}
