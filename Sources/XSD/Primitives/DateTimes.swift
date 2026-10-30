import RDFCore

// The date/time datatypes (XML Schema 1.1 Part 2 §3.3.7 to §3.3.15), each
// on the seven-property model with the properties its lexical
// representations give.

/// `xsd:dateTime` (§3.3.7).
extension dateTime {
    public typealias Value = SevenPropertyModel

    /// ·dateTimeLexicalMap·, for dateTimeLexicalRep:
    /// `yearFrag '-' monthFrag '-' dayFrag 'T' ((hourFrag ':' minuteFrag ':' secondFrag) | endOfDayFrag) timezoneFrag?`.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        let year = try reader.year()
        try reader.literal("-")
        let month = try reader.month()
        try reader.literal("-")
        let day = try reader.day()
        try reader.literal("T")
        let time = try reader.time()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        try SevenPropertyModel.checkDay(day, month: month, year: year)
        return SevenPropertyModel(year: year, month: month, day: day, hour: time.hour, minute: time.minute, second: time.second, timezoneOffset: timezone)
    }

    /// ·dateTimeCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        [value.yearFragment + "-" + value.monthFragment + "-" + value.dayFragment + "T" + value.timeFragment + value.timezoneFragment]
    }
}

/// `xsd:time` (§3.3.8).
extension time {
    public typealias Value = SevenPropertyModel

    /// ·timeLexicalMap·: the end of the day, `24:00:00`, is hour 0.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        let time = try reader.time()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        return SevenPropertyModel(year: nil, month: nil, day: nil, hour: time.hour == 24 ? 0 : time.hour, minute: time.minute, second: time.second, timezoneOffset: timezone)
    }

    /// ·timeCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        [value.timeFragment + value.timezoneFragment]
    }
}

/// `xsd:date` (§3.3.9).
extension date {
    public typealias Value = SevenPropertyModel

    /// ·dateLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        let year = try reader.year()
        try reader.literal("-")
        let month = try reader.month()
        try reader.literal("-")
        let day = try reader.day()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        try SevenPropertyModel.checkDay(day, month: month, year: year)
        return SevenPropertyModel(year: year, month: month, day: day, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·dateCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        [value.yearFragment + "-" + value.monthFragment + "-" + value.dayFragment + value.timezoneFragment]
    }
}

/// `xsd:gYearMonth` (§3.3.10).
extension gYearMonth {
    public typealias Value = SevenPropertyModel

    /// ·gYearMonthLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        let year = try reader.year()
        try reader.literal("-")
        let month = try reader.month()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        return SevenPropertyModel(year: year, month: month, day: nil, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gYearMonthCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        [value.yearFragment + "-" + value.monthFragment + value.timezoneFragment]
    }
}

/// `xsd:gYear` (§3.3.11).
extension gYear {
    public typealias Value = SevenPropertyModel

    /// ·gYearLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        let year = try reader.year()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        return SevenPropertyModel(year: year, month: nil, day: nil, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gYearCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        [value.yearFragment + value.timezoneFragment]
    }
}

/// `xsd:gMonthDay` (§3.3.12).
extension gMonthDay {
    public typealias Value = SevenPropertyModel

    /// ·gMonthDayLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        try reader.literal("--")
        let month = try reader.month()
        try reader.literal("-")
        let day = try reader.day()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        try SevenPropertyModel.checkDay(day, month: month, year: nil)
        return SevenPropertyModel(year: nil, month: month, day: day, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gMonthDayCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        ["--" + value.monthFragment + "-" + value.dayFragment + value.timezoneFragment]
    }
}

/// `xsd:gDay` (§3.3.13).
extension gDay {
    public typealias Value = SevenPropertyModel

    /// ·gDayLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        try reader.literal("---")
        let day = try reader.day()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        return SevenPropertyModel(year: nil, month: nil, day: day, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gDayCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        ["---" + value.dayFragment + value.timezoneFragment]
    }
}

/// `xsd:gMonth` (§3.3.14).
extension gMonth {
    public typealias Value = SevenPropertyModel

    /// ·gMonthLexicalMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> SevenPropertyModel {
        var reader = SevenPropertyModel.Reader(lexicalForm)
        try reader.literal("--")
        let month = try reader.month()
        let timezone = try reader.timezone()
        guard reader.isAtEnd else { throw .illTyped }
        return SevenPropertyModel(year: nil, month: month, day: nil, hour: nil, minute: nil, second: nil, timezoneOffset: timezone)
    }

    /// ·gMonthCanonicalMap·.
    public static func representations(of value: SevenPropertyModel) -> [String] {
        ["--" + value.monthFragment + value.timezoneFragment]
    }
}
