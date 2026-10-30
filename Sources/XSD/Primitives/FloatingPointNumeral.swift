import RDFCore

/// The lexical and canonical mappings `xsd:float` and `xsd:double` share
/// (XML Schema 1.1 Part 2 §3.3.4, §3.3.5), for an IEEE binary format.
enum FloatingPointNumeral<Number: BinaryFloatingPoint & LosslessStringConvertible> where Number.RawSignificand: FixedWidthInteger, Number.RawExponent: FixedWidthInteger {
    /// ·floatLexicalMap· and ·doubleLexicalMap·, for floatRep:
    /// `(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)([Ee](\+|-)?[0-9]+)?|(\+|-)?INF|NaN`.
    /// The decimal number is rounded to the nearest number of the format,
    /// ties to even, as ·floatingPointRound· gives it; RDF 1.2 Concepts
    /// §5.1 requires that rounding.
    static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> Number {
        switch lexicalForm {
        case "INF", "+INF": return .infinity
        case "-INF": return -.infinity
        case "NaN": return .nan
        default: break
        }
        var rest = Substring(lexicalForm)
        if rest.hasPrefix("+") || rest.hasPrefix("-") { rest = rest.dropFirst() }
        let mantissa = rest.prefix { $0 == "." || ($0.isASCII && $0.isNumber) }
        rest = rest.dropFirst(mantissa.count)
        guard DecimalNumber(unsignedNumeral: mantissa) != nil, mantissa.allSatisfy({ $0 == "." || $0.isNumber }) else { throw .illTyped }
        if let marker = rest.first {
            guard marker == "e" || marker == "E" else { throw .illTyped }
            rest = rest.dropFirst()
            if rest.hasPrefix("+") || rest.hasPrefix("-") { rest = rest.dropFirst() }
            guard !rest.isEmpty, rest.allSatisfy({ $0.isASCII && $0.isNumber }) else { throw .illTyped }
        }
        // The numeral is a decimal numeral now, which Swift reads with the
        // same correctly rounded conversion.
        guard let number = Number(lexicalForm) else { throw .illTyped }
        return number
    }

    /// ·floatCanonicalMap· and ·doubleCanonicalMap· (§E.1): `INF`, `-INF`,
    /// `NaN`, `0.0E0` and `-0.0E0`, and otherwise the scientific numeral of
    /// the shortest rounding of the number's exact decimal value that rounds
    /// back to it.
    static func canonicalForm(_ number: Number) -> String {
        if number.isNaN { return "NaN" }
        if number.isInfinite { return number < 0 ? "-INF" : "INF" }
        if number.isZero { return number.sign == .minus ? "-0.0E0" : "0.0E0" }
        let sign = number < 0 ? "-" : ""

        // |f| = c × 10^e exactly, with c the smallest such integer.
        let bias = (1 << (Number.exponentBitCount - 1)) - 1
        let fractionBits = Number.significandBitCount
        let exponentBits = Int(number.exponentBitPattern)
        var m = BigInteger(Int(number.significandBitPattern))
        var k: Int
        if exponentBits == 0 {
            k = 1 - bias - fractionBits
        } else {
            m += BigInteger(1 << fractionBits)
            k = exponentBits - bias - fractionBits
        }
        var c = m
        var e = 0
        if k >= 0 {
            for _ in 0..<k { c *= BigInteger(2) }
        } else {
            for _ in 0..<(-k) { c *= BigInteger(5) }
            e = k
        }
        var digits = c.digits
        while digits.count > 1, digits.hasSuffix("0") {
            digits.removeLast()
            e += 1
        }

        // The largest l for which round(c, l) × 10^(e+l) rounds back to |f|.
        for removed in stride(from: digits.count - 1, through: 0, by: -1) {
            var kept = BigInteger(digits: digits.prefix(digits.count - removed))!
            if removed > 0, let next = digits.dropFirst(digits.count - removed).first, next >= "5" {
                kept += BigInteger(1)
            }
            let exponent = e + removed
            guard Number("\(kept.digits)e\(exponent)") == number.magnitude else { continue }
            return sign + scientific(kept.digits, exponent)
        }
        return sign + scientific(digits, e)
    }

    /// ·scientificCanonicalMap· of `digits × 10^exponent`: one digit before
    /// the point, at least one after, and the exponent.
    private static func scientific(_ digits: String, _ exponent: Int) -> String {
        var digits = digits
        var exponent = exponent
        while digits.count > 1, digits.hasSuffix("0") {
            digits.removeLast()
            exponent += 1
        }
        let fraction = digits.dropFirst()
        return String(digits.prefix(1)) + "." + (fraction.isEmpty ? "0" : String(fraction)) + "E" + String(exponent + fraction.count)
    }
}

extension float {
    public typealias Value = Float

    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> Float {
        try FloatingPointNumeral<Float>.lexicalMapping(lexicalForm)
    }

    public static func representations(of value: Float) -> [String] {
        [FloatingPointNumeral<Float>.canonicalForm(value)]
    }
}

extension double {
    public typealias Value = Double

    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> Double {
        try FloatingPointNumeral<Double>.lexicalMapping(lexicalForm)
    }

    public static func representations(of value: Double) -> [String] {
        [FloatingPointNumeral<Double>.canonicalForm(value)]
    }
}

extension Float: FacetMeasurable {}
extension Double: FacetMeasurable {}
