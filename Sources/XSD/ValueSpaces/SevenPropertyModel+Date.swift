import Foundation

/// A dateTime value as a Foundation `Date`, a point on the time line, and
/// back. The generated `XSD.dateTime` and the datatypes derived from it
/// give their `date` views through these.
///
/// Both count on the time line of ·timeOnTimeline· (§E.3.4), the proleptic
/// Gregorian calendar with year 0 for 1 BCE, never through `Calendar`,
/// whose Gregorian calendar is Julian before October 1582.
extension SevenPropertyModel {
    /// The seconds from 0001-01-01T00:00:00Z, where ·timeOnTimeline·
    /// counts from, to 2001-01-01T00:00:00Z, Foundation's reference date.
    static let referenceDateOnTimeline = 63_113_904_000

    /// The days from 0001-01-01 to 1970-01-01.
    private static let daysToUnixEpoch = 719_162

    /// The point in time the value is, when it has a timezone offset, which
    /// places it on the time line; a value without one is a local time, at
    /// as many points as there are offsets, and has none (§3.3.7: "values
    /// ... without timezone offsets are ... 'local' values").
    var date: Date? {
        guard timezoneOffset != nil else { return nil }
        return Date(timeIntervalSinceReferenceDate: secondsSinceReferenceDate)
    }

    /// The point in time the value is, its local time read in `timeZone`
    /// when it has no timezone offset of its own.
    func date(assuming timeZone: TimeZone) -> Date {
        if let date { return date }
        let local = secondsSinceReferenceDate
        // The offset in effect at the instant, which the offset at the
        // local time read as UTC approaches.
        var offset = timeZone.secondsFromGMT(for: Date(timeIntervalSinceReferenceDate: local))
        offset = timeZone.secondsFromGMT(for: Date(timeIntervalSinceReferenceDate: local - TimeInterval(offset)))
        return Date(timeIntervalSinceReferenceDate: local - TimeInterval(offset))
    }

    /// The value's seconds from the reference date, its local time read as
    /// UTC when it has no timezone offset.
    private var secondsSinceReferenceDate: TimeInterval {
        TimeInterval((timeOnTimeline - DecimalNumber(Self.referenceDateOnTimeline)).description) ?? .nan
    }

    /// The dateTime value of `date` in UTC, timezone offset 0 (`Z`), to the
    /// microsecond: a `Date` is a binary floating-point count of seconds,
    /// whose fraction has no exact decimal value to give ·second·.
    init(_ date: Date) {
        let microseconds = Int((date.timeIntervalSinceReferenceDate * 1_000_000).rounded())
        let (seconds, fraction) = Self.floorDivided(microseconds, 1_000_000)
        let (days, secondOfDay) = Self.floorDivided(seconds + Self.referenceDateOnTimeline, 86_400)
        // civil_from_days (Howard Hinnant, "chrono-Compatible Low-Level Date
        // Algorithms"), proleptic Gregorian, from days since 1970-01-01.
        let z = days - Self.daysToUnixEpoch + 719_468
        let era = Self.floorDivided(z, 146_097).quotient
        let dayOfEra = z - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1_460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfYear + 2) / 153
        let day = dayOfYear - (153 * shiftedMonth + 2) / 5 + 1
        let month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9
        let year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0)
        self.init(
            year: BigInteger(year),
            month: month,
            day: day,
            hour: secondOfDay / 3_600,
            minute: secondOfDay % 3_600 / 60,
            second: DecimalNumber(significand: BigInteger(secondOfDay % 60 * 1_000_000 + fraction), scale: 6),
            timezoneOffset: 0
        )
    }

    private static func floorDivided(_ a: Int, _ b: Int) -> (quotient: Int, remainder: Int) {
        let remainder = a % b
        return remainder < 0 ? (a / b - 1, remainder + b) : (a / b, remainder)
    }
}
