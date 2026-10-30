import RDFCore

/// A duration: a number of months and a number of seconds, the value space
/// of `xsd:duration` and of `xsd:yearMonthDuration` and
/// `xsd:dayTimeDuration` (XML Schema 1.1 Part 2 §3.3.6: "Duration values
/// can be modelled as two-property tuples", ·months· an integer and
/// ·seconds· a decimal number, both of one sign).
///
/// Two durations are equal when their months and their seconds are
/// (§3.3.6.2: "Equality of duration is defined in terms of equality of
/// months and seconds"), so `P1Y` and `P12M` are one value, and `P1D` and
/// `PT24H` another.
public struct DurationValue: Hashable, Sendable {
    /// The ·months·.
    public let months: DecimalNumber
    /// The ·seconds·.
    public let seconds: DecimalNumber

    init(months: DecimalNumber, seconds: DecimalNumber) {
        self.months = months
        self.seconds = seconds
    }

    /// The lexical mapping, ·durationMap· (§E.2): `'-'? 'P'` followed by
    /// years, months, days and a time part, each optional but not all.
    init(lexicalForm text: String) throws(DatatypeError) {
        var scalars = Substring(text)
        let isNegative = scalars.hasPrefix("-")
        if isNegative { scalars = scalars.dropFirst() }
        guard scalars.hasPrefix("P") else { throw .illTyped }
        scalars = scalars.dropFirst()

        // Each field: digits (with a fraction for seconds) and a designator,
        // in the order the grammar gives them.
        let designators: [(Character, inTime: Bool)] = [("Y", false), ("M", false), ("D", false), ("H", true), ("M", true), ("S", true)]
        var values: [DecimalNumber?] = Array(repeating: nil, count: designators.count)
        var inTime = false
        var timeFields = 0
        var next = 0
        while !scalars.isEmpty {
            if scalars.first == "T" {
                guard !inTime else { throw .illTyped }
                inTime = true
                scalars = scalars.dropFirst()
                next = max(next, 3)
                continue
            }
            let numeral = scalars.prefix { $0.isASCII && ($0.isNumber || $0 == ".") }
            scalars = scalars.dropFirst(numeral.count)
            guard !numeral.isEmpty, let designator = scalars.first else { throw .illTyped }
            scalars = scalars.dropFirst()
            guard let index = designators.indices.first(where: { $0 >= next && designators[$0].0 == designator && designators[$0].inTime == inTime }) else {
                throw .illTyped
            }
            // Only seconds may have a fraction (duSecondFrag).
            guard numeral.allSatisfy(\.isNumber) || index == 5, let value = DecimalNumber(unsignedNumeral: numeral) else {
                throw .illTyped
            }
            values[index] = value
            if inTime { timeFields += 1 }
            next = index + 1
        }
        // 'T' needs a field after it, and the representation needs one field.
        guard !(inTime && timeFields == 0), values.contains(where: { $0 != nil }) else { throw .illTyped }

        func value(_ index: Int) -> DecimalNumber { values[index] ?? .zero }
        var months = value(0) * DecimalNumber(12) + value(1)
        var seconds = value(2) * DecimalNumber(86_400) + value(3) * DecimalNumber(3_600) + value(4) * DecimalNumber(60) + value(5)
        if isNegative {
            months = -months
            seconds = -seconds
        }
        self.init(months: months, seconds: seconds)
    }

    /// ·durationCanonicalMap· (§E.2).
    var canonicalForm: String {
        let sign = months.isNegative || seconds.isNegative ? "-" : ""
        if !months.isZero && !seconds.isZero {
            return sign + "P" + Self.yearMonthFragment(months.magnitude) + Self.dayTimeFragment(seconds.magnitude)
        }
        if !months.isZero {
            return sign + "P" + Self.yearMonthFragment(months.magnitude)
        }
        return sign + "P" + Self.dayTimeFragment(seconds.magnitude)
    }

    /// The lexical representations that denote the duration, the canonical
    /// one first. The zero duration's canonical representation, `PT0S`, is
    /// not in the lexical space of `xsd:yearMonthDuration`, which writes it
    /// with ·yearMonthDurationCanonicalMap·: `P0M` (§3.4.26.1).
    var representations: [String] {
        guard months.isZero, seconds.isZero else { return [canonicalForm] }
        return [canonicalForm, "P" + Self.yearMonthFragment(months)]
    }

    /// ·duYearMonthCanonicalFragmentMap·.
    private static func yearMonthFragment(_ months: DecimalNumber) -> String {
        let (years, rest) = months.floorDivided(by: 12)
        let month = rest.description
        if years.isZero { return month + "M" }
        if rest.isZero { return years.digits + "Y" }
        return years.digits + "Y" + month + "M"
    }

    /// ·duDayTimeCanonicalFragmentMap·.
    private static func dayTimeFragment(_ seconds: DecimalNumber) -> String {
        guard !seconds.isZero else { return "T0S" }
        let (days, inDay) = seconds.floorDivided(by: 86_400)
        let (hours, inHour) = inDay.floorDivided(by: 3_600)
        let (minutes, second) = inHour.floorDivided(by: 60)
        var text = days.isZero ? "" : days.digits + "D"
        if !(hours.isZero && minutes.isZero && second.isZero) {
            text += "T"
            if !hours.isZero { text += hours.digits + "H" }
            if !minutes.isZero { text += minutes.digits + "M" }
            if !second.isZero { text += (second.isInteger ? second.description : second.decimalPointNumeral) + "S" }
        }
        return text
    }
}
