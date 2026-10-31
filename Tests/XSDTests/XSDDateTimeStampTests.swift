import Foundation
import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDateTimeStampTests {
    /// xsd:dateTimeStamp is xsd:dateTime with its explicitTimezone facet
    /// `required` (derived.nxsd): every value is a point in time.
    @Test func requiresATimezone() throws {
        let stamp = try XSD.dateTimeStamp(lexicalForm: "2026-10-30T12:00:00+01:00")
        #expect(try stamp.value == XSD.dateTime(lexicalForm: "2026-10-30T11:00:00Z").value)
        #expect(stamp.canonicalLexicalForm == "2026-10-30T12:00:00+01:00")
        #expect(stamp.date == ISO8601DateFormatter().date(from: "2026-10-30T11:00:00Z"))
        #expect((stamp as Any) is RDFS.Literal)
        #expect(throws: DatatypeError.illTyped) { try XSD.dateTimeStamp(lexicalForm: "2026-10-30T12:00:00") }
    }

    /// A Date is a dateTimeStamp in UTC.
    @Test func isMadeFromADate() {
        let stamp = XSD.dateTimeStamp(Date(timeIntervalSinceReferenceDate: 0))
        #expect(stamp.canonicalLexicalForm == "2001-01-01T00:00:00Z")
        #expect(stamp.value.timezoneOffset == 0)
    }
}
