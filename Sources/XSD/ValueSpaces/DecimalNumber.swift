/// A decimal number: a number that a finite decimal numeral denotes, the
/// value space of `xsd:decimal` and of the datatypes derived from it, such
/// as `xsd:integer` and `xsd:long` (XML Schema 1.1 Part 2 §3.3.3: "the
/// ·value space· of decimal is the set of numbers that can be obtained by
/// dividing an integer by a non-negative power of ten").
///
/// The number is `significand × 10^−scale`, kept with no trailing zero in
/// its fraction, so equal numbers have equal representations: `1.50` and
/// `1.5` are one value. Neither part is bounded.
public struct DecimalNumber: Hashable, Sendable, Comparable, CustomStringConvertible {
    var significand: BigInteger
    /// The number of fraction digits, with no trailing zero.
    private(set) var scale: Int

    init(significand: BigInteger, scale: Int) {
        var significand = significand
        var scale = scale
        while scale > 0 {
            let (quotient, remainder) = significand.floorDivided(by: 10)
            guard remainder == 0 else { break }
            significand = quotient
            scale -= 1
        }
        if scale < 0 {
            significand = significand.timesPowerOfTen(-scale)
            scale = 0
        }
        self.significand = significand
        self.scale = significand.isZero ? 0 : scale
    }

    init(_ integer: BigInteger) {
        self.init(significand: integer, scale: 0)
    }

    /// The integer `value`.
    public init(_ value: Int) {
        self.init(BigInteger(value))
    }

    static let zero = DecimalNumber(0)

    /// The number an unsigned numeral of digits with an optional fraction
    /// denotes: ·unsignedNoDecimalMap· and ·unsignedDecimalPtMap· (§E.1).
    init?(unsignedNumeral text: some StringProtocol, isNegative: Bool = false) {
        let parts = text.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let whole = String(parts[0])
        let fraction = parts.count > 1 ? String(parts[1]) : ""
        guard !(whole.isEmpty && fraction.isEmpty),
              let significand = BigInteger(digits: whole + fraction, isNegative: isNegative) else { return nil }
        self.init(significand: significand, scale: fraction.count)
    }

    public var isNegative: Bool { significand.isNegative }

    public var isZero: Bool { significand.isZero }

    /// Whether the number is an integer.
    public var isInteger: Bool { scale == 0 }

    /// The number of fraction digits it needs, the measure `fractionDigits`
    /// constrains (§4.3.12).
    public var fractionDigitCount: Int { scale }

    /// The number of digits it needs, the measure `totalDigits` constrains
    /// (§4.3.11: the number is i ÷ 10ʲ with |i| < 10ⁿ and j ≤ n): the
    /// digits of `significand`, and at least the fraction digits.
    public var totalDigitCount: Int {
        max(significand.magnitude.digits.count, scale)
    }

    /// The integer, when it is one and fits in an `Int`.
    public var int: Int? { isInteger ? significand.int : nil }

    var magnitude: DecimalNumber { DecimalNumber(significand: significand.magnitude, scale: scale) }

    /// `self ·div· 1` and `self ·mod· 1`: the integer below or equal to the
    /// number, and what remains (§D.1).
    var integerAndFraction: (integer: BigInteger, fraction: DecimalNumber) {
        guard scale > 0 else { return (significand, .zero) }
        let divisor = BigInteger(digits: "1" + String(repeating: "0", count: scale))!
        var integer = BigInteger(digits: String(significand.magnitude.digits.dropLast(scale)).isEmpty ? "0" : String(significand.magnitude.digits.dropLast(scale)))!
        if significand.isNegative {
            integer = -integer - BigInteger(1)
        }
        let fraction = DecimalNumber(significand: significand - integer * divisor, scale: scale)
        return (integer, fraction)
    }

    /// `self ·div· divisor` and `self ·mod· divisor` for a positive integer
    /// divisor (§D.1).
    func floorDivided(by divisor: Int) -> (quotient: BigInteger, remainder: DecimalNumber) {
        let (integer, fraction) = integerAndFraction
        let (quotient, remainder) = integer.floorDivided(by: divisor)
        return (quotient, DecimalNumber(BigInteger(remainder)) + fraction)
    }

    // MARK: Arithmetic

    private static func aligned(_ lhs: DecimalNumber, _ rhs: DecimalNumber) -> (BigInteger, BigInteger, Int) {
        let scale = max(lhs.scale, rhs.scale)
        return (lhs.significand.timesPowerOfTen(scale - lhs.scale), rhs.significand.timesPowerOfTen(scale - rhs.scale), scale)
    }

    public static func + (lhs: DecimalNumber, rhs: DecimalNumber) -> DecimalNumber {
        let (a, b, scale) = aligned(lhs, rhs)
        return DecimalNumber(significand: a + b, scale: scale)
    }

    public static func - (lhs: DecimalNumber, rhs: DecimalNumber) -> DecimalNumber {
        let (a, b, scale) = aligned(lhs, rhs)
        return DecimalNumber(significand: a - b, scale: scale)
    }

    public static prefix func - (value: DecimalNumber) -> DecimalNumber {
        DecimalNumber(significand: -value.significand, scale: value.scale)
    }

    public static func * (lhs: DecimalNumber, rhs: DecimalNumber) -> DecimalNumber {
        DecimalNumber(significand: lhs.significand * rhs.significand, scale: lhs.scale + rhs.scale)
    }

    public static func < (lhs: DecimalNumber, rhs: DecimalNumber) -> Bool {
        let (a, b, _) = aligned(lhs, rhs)
        return a < b
    }

    // MARK: Canonical mappings (§E.1)

    /// ·fractionDigitsCanonicalFragmentMap·: the digits of a fraction
    /// `0 ≤ f < 1`, up to its last significant digit.
    var fractionDigits: String {
        let digits = significand.magnitude.digits
        guard scale > 0 else { return "0" }
        return String(repeating: "0", count: max(0, scale - digits.count)) + digits.suffix(scale)
    }

    /// ·decimalCanonicalMap·: the numeral with no decimal point for an
    /// integer (·noDecimalPtCanonicalMap·), and with one otherwise
    /// (·decimalPtCanonicalMap·).
    public var description: String {
        isInteger ? significand.description : decimalPointNumeral
    }

    /// ·decimalPtCanonicalMap·: the numeral with a decimal point and at
    /// least one fraction digit.
    var decimalPointNumeral: String {
        let (integer, fraction) = magnitude.integerAndFraction
        return (isNegative ? "-" : "") + integer.digits + "." + fraction.fractionDigits
    }
}
