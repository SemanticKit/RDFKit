import RDFCore

/// A value of the date/time datatypes, `xsd:dateTime`, `xsd:time`,
/// `xsd:date`, `xsd:gYearMonth`, `xsd:gYear`, `xsd:gMonthDay`, `xsd:gDay`,
/// `xsd:gMonth` and those derived from them: XML Schema 1.1 Part 2 §D.2.1,
/// the "date/timeSevenPropertyModel", with ·year·, ·month·, ·day·, ·hour·,
/// ·minute·, ·second· and ·timezoneOffset·, each absent where the datatype
/// has none.
///
/// Values are equal when they are at the same point of the time line
/// (§3.3.7.2, "dateTime values are ordered by their ·timeOnTimeline·
/// value"): `2026-10-30T12:00:00Z` and `2026-10-30T13:00:00+01:00` are one
/// value. A value with a timezone offset and one without are never equal.
public struct SevenPropertyModel: Hashable, Sendable {
    /// The ·year·, an integer of any size; 0 is 1 BCE.
    public let year: BigInteger?
    /// The ·month·, 1 to 12.
    public let month: Int?
    /// The ·day·, 1 to 31.
    public let day: Int?
    /// The ·hour·, 0 to 23.
    public let hour: Int?
    /// The ·minute·, 0 to 59.
    public let minute: Int?
    /// The ·second·, at least 0 and less than 60.
    public let second: DecimalNumber?
    /// The ·timezoneOffset· in minutes, −840 to 840.
    public let timezoneOffset: Int?

    /// ·newDateTime· (§E.3.2): the value with the properties given,
    /// normalized by ·normalizeSecond·, so that hour 24 is the first instant
    /// of the next day.
    ///
    /// The lexical mappings give every other property in range, so only
    /// hour 24 is normalized: ·newDateTime· supplies year 1 for an absent
    /// year, a common year, which would move gMonthDay's `--02-29` to March.
    init(year: BigInteger?, month: Int?, day: Int?, hour: Int?, minute: Int?, second: DecimalNumber?, timezoneOffset: Int?) {
        var yr = year ?? BigInteger(1)
        var mo = month ?? 1
        var da = day ?? 1
        var hr = hour ?? 0
        var mi = minute ?? 0
        var se = second ?? .zero
        if hr == 24 {
            Self.normalizeSecond(&yr, &mo, &da, &hr, &mi, &se)
        }
        self.year = year == nil ? nil : yr
        self.month = month == nil ? nil : mo
        self.day = day == nil ? nil : da
        self.hour = hour == nil ? nil : hr
        self.minute = minute == nil ? nil : mi
        self.second = second == nil ? nil : se
        self.timezoneOffset = timezoneOffset
    }

    // MARK: Equality, on the time line

    public static func == (lhs: SevenPropertyModel, rhs: SevenPropertyModel) -> Bool {
        (lhs.timezoneOffset == nil) == (rhs.timezoneOffset == nil) && lhs.timeOnTimeline == rhs.timeOnTimeline
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(timezoneOffset == nil)
        hasher.combine(timeOnTimeline)
    }

    /// ·timeOnTimeline· (§E.3.4): the number of seconds from the start of
    /// year 1 to the value, with absent properties given the values the
    /// algorithm gives them.
    var timeOnTimeline: DecimalNumber {
        let yr = year.map { $0 - BigInteger(1) } ?? BigInteger(1971)
        let mo = month ?? 12
        let da = day.map { $0 - 1 } ?? (Self.daysInMonth(yr + BigInteger(1), mo) - 1)
        let hr = hour ?? 0
        var mi = minute ?? 0
        let se = second ?? .zero
        if let timezoneOffset { mi -= timezoneOffset }
        var total = yr * BigInteger(31_536_000)
        let leapDays = yr.floorDivided(by: 400).quotient - yr.floorDivided(by: 100).quotient + yr.floorDivided(by: 4).quotient
        total += BigInteger(86_400) * leapDays
        var days = 0
        for m in 1..<mo { days += Self.daysInMonth(yr + BigInteger(1), m) }
        total += BigInteger(86_400 * (days + da) + 3_600 * hr + 60 * mi)
        return DecimalNumber(total) + se
    }

    // MARK: Auxiliary functions (§E.3.1, §E.3.2)

    /// ·daysInMonth·: the number of the last day of month `m` of year `y`.
    static func daysInMonth(_ y: BigInteger?, _ m: Int) -> Int {
        switch m {
        case 2:
            guard let y else { return 28 }
            let leap = y.floorDivided(by: 400).remainder == 0
                || (y.floorDivided(by: 4).remainder == 0 && y.floorDivided(by: 100).remainder != 0)
            return leap ? 29 : 28
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }

    private static func floorDivMod(_ a: Int, _ b: Int) -> (Int, Int) {
        let q = a >= 0 ? a / b : -((-a + b - 1) / b)
        return (q, a - q * b)
    }

    /// ·normalizeMonth·.
    private static func normalizeMonth(_ yr: inout BigInteger, _ mo: inout Int) {
        let (carry, month) = floorDivMod(mo - 1, 12)
        yr += BigInteger(carry)
        mo = month + 1
    }

    /// ·normalizeDay·.
    private static func normalizeDay(_ yr: inout BigInteger, _ mo: inout Int, _ da: inout Int) {
        normalizeMonth(&yr, &mo)
        while da <= 0 || da > daysInMonth(yr, mo) {
            if da > daysInMonth(yr, mo) {
                da -= daysInMonth(yr, mo)
                mo += 1
                normalizeMonth(&yr, &mo)
            } else {
                mo -= 1
                normalizeMonth(&yr, &mo)
                da += daysInMonth(yr, mo)
            }
        }
    }

    /// ·normalizeMinute·.
    private static func normalizeMinute(_ yr: inout BigInteger, _ mo: inout Int, _ da: inout Int, _ hr: inout Int, _ mi: inout Int) {
        let (hours, minute) = floorDivMod(mi, 60)
        hr += hours
        mi = minute
        let (days, hour) = floorDivMod(hr, 24)
        da += days
        hr = hour
        normalizeDay(&yr, &mo, &da)
    }

    /// ·normalizeSecond·.
    private static func normalizeSecond(_ yr: inout BigInteger, _ mo: inout Int, _ da: inout Int, _ hr: inout Int, _ mi: inout Int, _ se: inout DecimalNumber) {
        let (minutes, second) = se.floorDivided(by: 60)
        mi += minutes.int ?? 0
        se = second
        normalizeMinute(&yr, &mo, &da, &hr, &mi)
    }
}

// MARK: - Lexical mappings (§E.3.5)

extension SevenPropertyModel {
    /// The fields of a date/time lexical representation, read left to
    /// right from the fragments of the grammar (§3.3.7 to §3.3.15).
    struct Reader {
        private var rest: Substring

        init(_ text: String) {
            rest = Substring(text)
        }

        var isAtEnd: Bool { rest.isEmpty }

        mutating func literal(_ text: String) throws(DatatypeError) {
            guard rest.hasPrefix(text) else { throw .illTyped }
            rest = rest.dropFirst(text.count)
        }

        /// Exactly `count` ASCII digits.
        mutating func digits(_ count: Int) throws(DatatypeError) -> Int {
            let digits = rest.prefix(count)
            guard digits.count == count, digits.allSatisfy({ $0.isASCII && $0.isNumber }) else { throw .illTyped }
            rest = rest.dropFirst(count)
            return Int(digits)!
        }

        /// yearFrag ::= '-'? (([1-9] digit digit digit+)) | ('0' digit digit digit))
        mutating func year() throws(DatatypeError) -> BigInteger {
            let isNegative = rest.hasPrefix("-")
            if isNegative { rest = rest.dropFirst() }
            let digits = rest.prefix { $0.isASCII && $0.isNumber }
            guard digits.count >= 4, digits.count == 4 || digits.first != "0" else { throw .illTyped }
            rest = rest.dropFirst(digits.count)
            return BigInteger(digits: digits, isNegative: isNegative)!
        }

        /// monthFrag ::= ('0' [1-9]) | ('1' [0-2])
        mutating func month() throws(DatatypeError) -> Int {
            let month = try digits(2)
            guard (1...12).contains(month) else { throw .illTyped }
            return month
        }

        /// dayFrag ::= ('0' [1-9]) | ([12] digit) | ('3' [01])
        mutating func day() throws(DatatypeError) -> Int {
            let day = try digits(2)
            guard (1...31).contains(day) else { throw .illTyped }
            return day
        }

        /// The time of day: hourFrag ':' minuteFrag ':' secondFrag, or
        /// endOfDayFrag ::= '24:00:00' ('.' '0'+)?, which is hour 24.
        mutating func time() throws(DatatypeError) -> (hour: Int, minute: Int, second: DecimalNumber) {
            let hour = try digits(2)
            try literal(":")
            let minute = try digits(2)
            try literal(":")
            let whole = try digits(2)
            var fraction = ""
            if rest.hasPrefix(".") {
                rest = rest.dropFirst()
                let digits = rest.prefix { $0.isASCII && $0.isNumber }
                guard !digits.isEmpty else { throw .illTyped }
                rest = rest.dropFirst(digits.count)
                fraction = String(digits)
            }
            let second = DecimalNumber(unsignedNumeral: String(whole) + (fraction.isEmpty ? "" : "." + fraction))!
            if hour == 24 {
                guard minute == 0, whole == 0, fraction.allSatisfy({ $0 == "0" }) else { throw .illTyped }
                return (24, 0, .zero)
            }
            guard hour <= 23, minute <= 59, whole <= 59 else { throw .illTyped }
            return (hour, minute, second)
        }

        /// timezoneFrag ::= 'Z' | ('+' | '-') (('0' digit | '1' [0-3]) ':' minuteFrag | '14:00'),
        /// read at the end of the representation when present.
        mutating func timezone() throws(DatatypeError) -> Int? {
            if rest.isEmpty { return nil }
            if rest == "Z" {
                rest = rest.dropFirst()
                return 0
            }
            guard let sign = rest.first, sign == "+" || sign == "-" else { throw .illTyped }
            rest = rest.dropFirst()
            let hours = try digits(2)
            try literal(":")
            let minutes = try digits(2)
            guard rest.isEmpty, minutes <= 59, hours <= 13 || (hours == 14 && minutes == 0) else { throw .illTyped }
            let offset = hours * 60 + minutes
            return sign == "-" ? -offset : offset
        }
    }

    /// The constraint on day values, Day-of-month Values: within a year
    /// (§3.3.7.1), the last day of the month ·daysInMonth· gives; with no
    /// year (§3.3.12.1, gMonthDay), "no more than 29 if ·month· is 2".
    static func checkDay(_ day: Int, month: Int, year: BigInteger?) throws(DatatypeError) {
        let last = year == nil && month == 2 ? 29 : daysInMonth(year, month)
        guard day <= last else { throw .illTyped }
    }
}

// MARK: - Canonical mappings (§E.3.6)

extension SevenPropertyModel {
    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    /// ·yearCanonicalFragmentMap·.
    var yearFragment: String {
        guard let year else { return "" }
        if year.magnitude > BigInteger(9_999) { return year.description }
        let digits = year.magnitude.digits
        return (year.isNegative ? "-" : "") + String(repeating: "0", count: 4 - digits.count) + digits
    }

    var monthFragment: String { month.map(Self.twoDigits) ?? "" }
    var dayFragment: String { day.map(Self.twoDigits) ?? "" }

    /// ·hourCanonicalFragmentMap·, ·minuteCanonicalFragmentMap· and
    /// ·secondCanonicalFragmentMap·, colon-separated.
    var timeFragment: String {
        guard let hour, let minute, let second else { return "" }
        let (whole, fraction) = second.integerAndFraction
        var text = Self.twoDigits(hour) + ":" + Self.twoDigits(minute) + ":" + Self.twoDigits(whole.int ?? 0)
        if !fraction.isZero { text += "." + fraction.fractionDigits }
        return text
    }

    /// ·timezoneCanonicalFragmentMap·.
    var timezoneFragment: String {
        guard let timezoneOffset else { return "" }
        if timezoneOffset == 0 { return "Z" }
        let magnitude = abs(timezoneOffset)
        return (timezoneOffset < 0 ? "-" : "+") + Self.twoDigits(magnitude / 60) + ":" + Self.twoDigits(magnitude % 60)
    }
}

// MARK: - Order, for the bound facets

extension SevenPropertyModel: FacetMeasurable {
    public var facetHasTimezone: Bool? { timezoneOffset != nil }

    /// The partial order of §3.3.7.2 (dateTime): values that both have, or
    /// both lack, a timezone offset are ordered on the time line. A value
    /// with an offset and one without are ordered only when they are more
    /// than 14 hours apart, the widest offset.
    public static func facetOrder(_ lhs: SevenPropertyModel, _ rhs: SevenPropertyModel) -> FacetOrder? {
        func order(_ a: DecimalNumber, _ b: DecimalNumber) -> FacetOrder {
            a < b ? .less : a == b ? .equal : .greater
        }
        let (a, b) = (lhs.timeOnTimeline, rhs.timeOnTimeline)
        if (lhs.timezoneOffset == nil) == (rhs.timezoneOffset == nil) { return order(a, b) }
        let span = DecimalNumber(14 * 3_600)
        // The local value is somewhere within 14 hours either side.
        let (low, high) = lhs.timezoneOffset == nil ? (a - span, a + span) : (b - span, b + span)
        let other = lhs.timezoneOffset == nil ? b : a
        if high < other { return lhs.timezoneOffset == nil ? .less : .greater }
        if other < low { return lhs.timezoneOffset == nil ? .greater : .less }
        return nil
    }
}
