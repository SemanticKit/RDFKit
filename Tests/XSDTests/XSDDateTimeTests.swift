import Foundation
import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDateTimeTests {
    /// xsd:dateTime's value is the seven-property model (XSD 1.1 Part 2
    /// §3.3.7, §D.2.1), from a lexical form by ·dateTimeLexicalMap·, and it
    /// is a literal.
    @Test func mapsALexicalFormToItsSevenProperties() throws {
        let instant = try XSD.dateTime(lexicalForm: "2026-10-30T12:34:56.250-05:00")
        #expect(instant.value.year == BigInteger(2026))
        #expect(instant.value.month == 10)
        #expect(instant.value.day == 30)
        #expect(instant.value.hour == 12)
        #expect(instant.value.minute == 34)
        #expect(instant.value.second.map(\.description) == "56.25")
        #expect(instant.value.timezoneOffset == -300)
        #expect(instant.canonicalLexicalForm == "2026-10-30T12:34:56.25-05:00")
        #expect((instant as Any) is RDFS.Literal)
    }

    /// Values are equal at the same point of the time line (§3.3.7.2), and
    /// `24:00:00` is the first instant of the next day.
    @Test func equalsOnTheTimeLine() throws {
        #expect(try XSD.dateTime(lexicalForm: "2026-10-30T12:00:00Z") == XSD.dateTime(lexicalForm: "2026-10-30T13:00:00+01:00"))
        #expect(try XSD.dateTime(lexicalForm: "2026-12-31T24:00:00Z").canonicalLexicalForm == "2027-01-01T00:00:00Z")
        #expect(try XSD.dateTime(lexicalForm: "2026-10-30T12:00:00") != XSD.dateTime(lexicalForm: "2026-10-30T12:00:00Z"))
    }

    /// A lexical form outside the lexical space is ill-typed.
    @Test(arguments: [
        "2026-02-29T00:00:00",
        "2026-10-30",
        "2026-10-30T12:00",
        "2026-10-30T12:00:00+15:00",
        "26-10-30T12:00:00",
        " 2026-10-30T12:00:00Z",
    ])
    func rejectsWhatTheGrammarDoesNot(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.dateTime(lexicalForm: lexicalForm) }
    }

    /// A value with a timezone offset is a point in time, a Date; a local
    /// value is none until a time zone is assumed.
    @Test func isADateWithATimezoneOffset() throws {
        let reference = Date(timeIntervalSinceReferenceDate: 0)
        #expect(try XSD.dateTime(lexicalForm: "2001-01-01T00:00:00Z").date == reference)
        #expect(try XSD.dateTime(lexicalForm: "2001-01-01T01:00:00+01:00").date == reference)
        #expect(try XSD.dateTime(lexicalForm: "2026-10-30T12:34:56Z").date == ISO8601DateFormatter().date(from: "2026-10-30T12:34:56Z"))
        let local = try XSD.dateTime(lexicalForm: "2001-01-01T01:00:00")
        #expect(local.date == nil)
        #expect(local.date(assuming: try #require(TimeZone(secondsFromGMT: 3_600))) == reference)
        let utc = try XSD.dateTime(lexicalForm: "2001-01-01T00:00:00Z")
        #expect(utc.date(assuming: try #require(TimeZone(secondsFromGMT: 3_600))) == reference)
    }

    /// A Date is a dateTime in UTC, on the proleptic Gregorian calendar of
    /// ·timeOnTimeline·, before 1582 too: 1000 is no leap year.
    @Test func isMadeFromADate() throws {
        #expect(XSD.dateTime(Date(timeIntervalSinceReferenceDate: 0)).canonicalLexicalForm == "2001-01-01T00:00:00Z")
        #expect(XSD.dateTime(Date(timeIntervalSinceReferenceDate: -0.5)).canonicalLexicalForm == "2000-12-31T23:59:59.5Z")
        let medieval = try XSD.dateTime(lexicalForm: "1000-02-28T18:00:00-06:00")
        #expect(XSD.dateTime(try #require(medieval.date)).canonicalLexicalForm == "1000-03-01T00:00:00Z")
        let now = Date(timeIntervalSinceReferenceDate: 815_000_000.125)
        #expect(XSD.dateTime(now).date == now)
    }
}
