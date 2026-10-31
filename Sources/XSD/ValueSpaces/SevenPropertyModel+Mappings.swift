// The lexical and canonical mappings of the date/time datatypes, XML Schema
// 1.1 Part 2 §E.3.5 and §E.3.6, one per primitive, which the types
// XSDEmitter generates for them call by the primitive's name.

// MARK: - Lexical mappings (§E.3.5)

extension SevenPropertyModel {
    /// ·dateTimeLexicalMap·: `yearFrag '-' monthFrag '-' dayFrag 'T'
    /// ((hourFrag ':' minuteFrag ':' secondFrag) | endOfDayFrag)
    /// timezoneFrag?` (§3.3.7.2), with the day within its month.
    static func dateTimeLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        let year = try reader.year()
        try reader.literal("-")
        let month = try reader.month()
        try reader.literal("-")
        let day = try reader.day()
        try checkDay(day, month: month, year: year)
        try reader.literal("T")
        let time = try reader.time()
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: year, month: month, day: day, hour: time.hour, minute: time.minute, second: time.second, timezoneOffset: timezone)
    }

    /// ·timeLexicalMap·: `((hourFrag ':' minuteFrag ':' secondFrag) |
    /// endOfDayFrag) timezoneFrag?` (§3.3.8.2); `24:00:00` is `00:00:00`.
    static func timeLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        let time = try reader.time()
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: nil, month: nil, day: nil, hour: time.hour, minute: time.minute, second: time.second, timezoneOffset: timezone)
    }

    /// ·dateLexicalMap·: `yearFrag '-' monthFrag '-' dayFrag timezoneFrag?`
    /// (§3.3.9.2), with the day within its month.
    static func dateLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        let year = try reader.year()
        try reader.literal("-")
        let month = try reader.month()
        try reader.literal("-")
        let day = try reader.day()
        try checkDay(day, month: month, year: year)
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: year, month: month, day: day, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gYearMonthLexicalMap·: `yearFrag '-' monthFrag timezoneFrag?`
    /// (§3.3.10.2).
    static func gYearMonthLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        let year = try reader.year()
        try reader.literal("-")
        let month = try reader.month()
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: year, month: month, day: nil, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gYearLexicalMap·: `yearFrag timezoneFrag?` (§3.3.11.2).
    static func gYearLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        let year = try reader.year()
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: year, month: nil, day: nil, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gMonthDayLexicalMap·: `'--' monthFrag '-' dayFrag timezoneFrag?`
    /// (§3.3.12.2), with no more than 29 days in February.
    static func gMonthDayLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        try reader.literal("--")
        let month = try reader.month()
        try reader.literal("-")
        let day = try reader.day()
        try checkDay(day, month: month, year: nil)
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: nil, month: month, day: day, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gDayLexicalMap·: `'---' dayFrag timezoneFrag?` (§3.3.13.2).
    static func gDayLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        try reader.literal("---")
        let day = try reader.day()
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: nil, month: nil, day: day, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gMonthLexicalMap·: `'--' monthFrag timezoneFrag?` (§3.3.14.2).
    static func gMonthLexicalMap(_ text: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = Reader(text)
        try reader.literal("--")
        let month = try reader.month()
        let timezone = try reader.timezone()
        return SevenPropertyModel(year: nil, month: month, day: nil, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }
}

// MARK: - Canonical mappings (§E.3.6)

extension SevenPropertyModel {
    /// ·dateTimeCanonicalMap·.
    static func dateTimeCanonicalMap(_ value: SevenPropertyModel) -> String {
        value.yearFragment + "-" + value.monthFragment + "-" + value.dayFragment + "T" + value.timeFragment + value.timezoneFragment
    }

    /// ·timeCanonicalMap·.
    static func timeCanonicalMap(_ value: SevenPropertyModel) -> String {
        value.timeFragment + value.timezoneFragment
    }

    /// ·dateCanonicalMap·.
    static func dateCanonicalMap(_ value: SevenPropertyModel) -> String {
        value.yearFragment + "-" + value.monthFragment + "-" + value.dayFragment + value.timezoneFragment
    }

    /// ·gYearMonthCanonicalMap·.
    static func gYearMonthCanonicalMap(_ value: SevenPropertyModel) -> String {
        value.yearFragment + "-" + value.monthFragment + value.timezoneFragment
    }

    /// ·gYearCanonicalMap·.
    static func gYearCanonicalMap(_ value: SevenPropertyModel) -> String {
        value.yearFragment + value.timezoneFragment
    }

    /// ·gMonthDayCanonicalMap·.
    static func gMonthDayCanonicalMap(_ value: SevenPropertyModel) -> String {
        "--" + value.monthFragment + "-" + value.dayFragment + value.timezoneFragment
    }

    /// ·gDayCanonicalMap·.
    static func gDayCanonicalMap(_ value: SevenPropertyModel) -> String {
        "---" + value.dayFragment + value.timezoneFragment
    }

    /// ·gMonthCanonicalMap·.
    static func gMonthCanonicalMap(_ value: SevenPropertyModel) -> String {
        "--" + value.monthFragment + value.timezoneFragment
    }
}
