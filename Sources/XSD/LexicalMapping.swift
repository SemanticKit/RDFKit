/// The lexical mappings of the primitive datatypes (XML Schema 1.1 Part 2
/// §3.3, with the auxiliary functions of Appendix E), which map a literal's
/// lexical form to its value. XSDEmitter generates each datatype's
/// `init(lexicalForm:)` from the documents, as the composition of the
/// datatype's whiteSpace normalization, its patterns and its primitive's
/// lexical mapping:
///
///     public init(lexicalForm: String) throws(DatatypeError) {
///         self.init(try XSD.decimalLexicalMap(XSD.lexicalForm(lexicalForm, whiteSpace: .collapse)))
///     }
extension XSD {
    /// The values of the whiteSpace facet (§4.3.6), the normalization a
    /// literal's lexical form undergoes before its lexical mapping.
    enum WhiteSpace: Sendable {
        /// No normalization.
        case preserve
        /// Each tab, line feed and carriage return becomes a space.
        case replace
        /// After `replace`, runs of spaces become one, and leading and
        /// trailing spaces are removed.
        case collapse
    }

    /// The lexical form normalized as `whiteSpace` says (§4.3.6), checked
    /// against the pattern facets of each derivation step: the form matches
    /// one pattern of every step (§4.3.4.4: patterns of one step are
    /// alternatives, and each step's restricts its base's).
    ///
    /// - Throws: ``DatatypeError/illTyped`` when a step has no pattern the
    ///   normalized form matches.
    static func lexicalForm(_ text: String, whiteSpace: WhiteSpace, patterns: [[String]] = []) throws(DatatypeError) -> String {
        let form = normalized(text, whiteSpace: whiteSpace)
        for step in patterns {
            // A pattern matches the whole lexical form (§G.1: "regular
            // expressions ... are implicitly anchored at the head and tail").
            // XSDEmitter emits each pattern translated to a Swift regex that
            // Regex reads, matched scalar by scalar as XML Schema's are.
            guard step.contains(where: { form.wholeMatch(of: try! Regex($0).matchingSemantics(.unicodeScalar)) != nil }) else {
                throw .illTyped
            }
        }
        return form
    }

    static func normalized(_ text: String, whiteSpace: WhiteSpace) -> String {
        switch whiteSpace {
        case .preserve:
            return text
        case .replace:
            return String(String.UnicodeScalarView(text.unicodeScalars.map { isWhiteSpace($0) ? " " : $0 }))
        case .collapse:
            return text.unicodeScalars
                .split(whereSeparator: isWhiteSpace)
                .map { String(String.UnicodeScalarView($0)) }
                .joined(separator: " ")
        }
    }

    /// #x9 (tab), #xA (line feed), #xD (carriage return) and #x20 (space).
    private static func isWhiteSpace(_ scalar: Unicode.Scalar) -> Bool {
        scalar == "\t" || scalar == "\n" || scalar == "\r" || scalar == " "
    }

    // MARK: Lexical mappings (§3.3)

    /// ·stringLexicalMap· (§3.3.1.2): the identity, on the lexical space of
    /// `xsd:string`, the finite sequences of XML `Char`s (§3.3.1.1).
    static func stringLexicalMap(_ text: String) throws(DatatypeError) -> String {
        guard CharacterSequence.isXMLCharacters(text) else { throw .illTyped }
        return text
    }

    /// ·booleanLexicalMap· (§3.3.2.2): `true` and `1` map to true, `false`
    /// and `0` to false (booleanRep: `true|false|1|0`).
    static func booleanLexicalMap(_ text: String) throws(DatatypeError) -> Bool {
        switch text {
        case "true", "1": true
        case "false", "0": false
        default: throw .illTyped
        }
    }

    /// ·decimalLexicalMap· (§3.3.3.2): ·noDecimalMap· or ·decimalPtMap· of
    /// a decimalLexicalRep, `(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)`.
    static func decimalLexicalMap(_ text: String) throws(DatatypeError) -> DecimalNumber {
        guard let numeral = Numeral(text), numeral.exponent == nil else { throw .illTyped }
        return numeral.value
    }

    /// ·floatLexicalMap· (§3.3.4.2).
    static func floatLexicalMap(_ text: String) throws(DatatypeError) -> Float {
        try floatingPointLexicalMap(text)
    }

    /// ·doubleLexicalMap· (§3.3.5.2).
    static func doubleLexicalMap(_ text: String) throws(DatatypeError) -> Double {
        try floatingPointLexicalMap(text)
    }

    /// ·floatLexicalMap· and ·doubleLexicalMap·, on floatRep and doubleRep:
    /// `(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)([Ee](\+|-)?[0-9]+)?|(\+|-)?INF|NaN`.
    /// A numericalSpecialRep maps to its special value (·specialRepValue·,
    /// §E.1); a numeral that denotes zero to positive or negative zero as it
    /// begins with `-`; any other numeral to its value rounded to the
    /// nearest value of the datatype, ties to even (·floatingPointRound·,
    /// §E.1), which is what Swift's correctly rounded conversion from a
    /// decimal numeral gives, ±INF beyond the largest finite value among it.
    private static func floatingPointLexicalMap<Value: BinaryFloatingPoint & LosslessStringConvertible>(_ text: String) throws(DatatypeError) -> Value {
        switch text {
        case "INF", "+INF": return .infinity
        case "-INF": return -.infinity
        case "NaN": return .nan
        default: break
        }
        guard let numeral = Numeral(text) else { throw .illTyped }
        if numeral.value.isZero {
            return text.hasPrefix("-") ? -Value.zero : Value.zero
        }
        // The numeral, written with digits on both sides of any point, is
        // one the conversion reads as the same number.
        var mantissa = String(numeral.mantissa)
        if mantissa.hasPrefix(".") { mantissa = "0" + mantissa }
        if mantissa.hasSuffix(".") { mantissa += "0" }
        let sign = numeral.value.isNegative ? "-" : ""
        if let value = Value(sign + mantissa + (numeral.exponent.map { "e" + $0 } ?? "")) {
            return value
        }
        // No value from the conversion: the number is out of its range, and
        // rounds to ±INF above the largest finite value and to a zero of its
        // sign below the smallest. Its order of magnitude says which.
        let value: Value = numeral.order > 0 ? .infinity : .zero
        return numeral.value.isNegative ? -value : value
    }

    /// A numeral of the numeric lexical spaces (§E.1): a sign, digits with
    /// an optional decimal point, and, for scientificNotationNumeral, an
    /// exponent.
    private struct Numeral {
        /// The number the sign, digits and point denote (·noDecimalMap·,
        /// ·decimalPtMap·), before any exponent.
        var value: DecimalNumber
        /// The digits and point, without the sign.
        var mantissa: Substring
        /// The exponent's sign and digits.
        var exponent: Substring?

        init?(_ text: String) {
            var rest = Substring(text)
            let isNegative = rest.hasPrefix("-")
            if isNegative || rest.hasPrefix("+") { rest = rest.dropFirst() }
            let mantissa = rest.prefix { $0 != "e" && $0 != "E" }
            rest = rest.dropFirst(mantissa.count)
            guard let value = DecimalNumber(unsignedNumeral: mantissa, isNegative: isNegative) else { return nil }
            self.value = value
            self.mantissa = mantissa
            if rest.isEmpty {
                exponent = nil
                return
            }
            var digits = rest.dropFirst()
            if digits.hasPrefix("-") || digits.hasPrefix("+") { digits = digits.dropFirst() }
            guard !digits.isEmpty, digits.unicodeScalars.allSatisfy({ ("0"..."9").contains($0) }) else { return nil }
            exponent = rest.dropFirst()
        }

        /// For a numeral of a nonzero number, the n with the number in
        /// [10ⁿ⁻¹, 10ⁿ): positive when it is at least 1.
        var order: Int {
            let parts = mantissa.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
            let whole = parts[0].drop { $0 == "0" }
            let digits = whole.isEmpty ? -(parts.count > 1 ? parts[1].prefix { $0 == "0" }.count : 0) : whole.count
            guard let exponent else { return digits }
            let isNegative = exponent.hasPrefix("-")
            let power = exponent.drop { $0 == "-" || $0 == "+" }.drop { $0 == "0" }
            // An exponent of more digits than an Int holds is beyond every
            // floating-point range.
            guard power.count < 18 else { return isNegative ? -Int(Int32.max) : Int(Int32.max) }
            let value = Int(power.isEmpty ? "0" : String(power)) ?? 0
            return digits + (isNegative ? -value : value)
        }
    }
}

extension BigInteger {
    /// The integer a decimal number is, or `nil` when it is not one: the
    /// value space of `xsd:integer` within `xsd:decimal`'s (§3.4.13).
    init?(exactly decimal: DecimalNumber) {
        guard decimal.isInteger else { return nil }
        self = decimal.significand
    }
}
