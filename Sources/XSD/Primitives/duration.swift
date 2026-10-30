import RDFCore

/// `xsd:duration` (XML Schema 1.1 Part 2 §3.3.6), and through restriction
/// `xsd:yearMonthDuration` and `xsd:dayTimeDuration`.
extension duration {
    public typealias Value = DurationValue

    /// ·durationMap·.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> DurationValue {
        try DurationValue(lexicalForm: lexicalForm)
    }

    /// ·durationCanonicalMap·, then ·yearMonthDurationCanonicalMap· for the
    /// zero duration.
    public static func representations(of value: DurationValue) -> [String] {
        value.representations
    }
}

/// Durations are partially ordered (§3.3.6.2); the built-in definitions
/// put no bound on them, so no order is given here.
extension DurationValue: FacetMeasurable {}
