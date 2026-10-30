/// An integer of any size: the integers XML Schema 1.1 Part 2 builds its
/// numeric value spaces from (§D.1 Numerical Values: "The integers ... are
/// unbounded"), so `xsd:integer` and the properties of the other value
/// spaces are never bounded by `Int`.
///
/// The magnitude is kept in base 10⁹ limbs, least significant first, with
/// no leading zero limb; zero has no limbs and is never negative.
public struct BigInteger: Hashable, Sendable, Comparable, CustomStringConvertible {
    private static let base: UInt64 = 1_000_000_000

    /// Whether the integer is below zero.
    public private(set) var isNegative: Bool
    private var limbs: [UInt32]

    private init(isNegative: Bool, limbs: [UInt32]) {
        var limbs = limbs
        while limbs.last == 0 { limbs.removeLast() }
        self.limbs = limbs
        self.isNegative = limbs.isEmpty ? false : isNegative
    }

    static let zero = BigInteger(0)

    public init(_ value: Int) {
        var magnitude = value.magnitude
        var limbs: [UInt32] = []
        while magnitude > 0 {
            limbs.append(UInt32(magnitude % UInt(Self.base)))
            magnitude /= UInt(Self.base)
        }
        self.init(isNegative: value < 0, limbs: limbs)
    }

    /// The integer the decimal digits `digits` denote, or `nil` when `digits`
    /// is empty or holds anything but the digits 0 to 9.
    init?(digits: some StringProtocol, isNegative: Bool = false) {
        let scalars = Array(digits.unicodeScalars)
        guard !scalars.isEmpty, scalars.allSatisfy({ ("0"..."9").contains($0) }) else { return nil }
        var limbs: [UInt32] = []
        var end = scalars.count
        while end > 0 {
            let start = max(0, end - 9)
            var limb: UInt32 = 0
            for scalar in scalars[start..<end] { limb = limb * 10 + (scalar.value - 48) }
            limbs.append(limb)
            end = start
        }
        self.init(isNegative: isNegative, limbs: limbs)
    }

    /// Whether the integer is zero.
    public var isZero: Bool { limbs.isEmpty }

    var magnitude: BigInteger { BigInteger(isNegative: false, limbs: limbs) }

    /// The value as an `Int`, when it fits.
    public var int: Int? {
        var value = 0
        for limb in limbs.reversed() {
            let (scaled, overflow) = value.multipliedReportingOverflow(by: Int(Self.base))
            guard !overflow else { return nil }
            let (sum, overflow2) = scaled.addingReportingOverflow(Int(limb))
            guard !overflow2 else { return nil }
            value = sum
        }
        return isNegative ? -value : value
    }

    /// The decimal digits of the magnitude, with no leading zero ("0" for zero).
    var digits: String {
        guard let last = limbs.last else { return "0" }
        var text = String(last)
        for limb in limbs.dropLast().reversed() {
            let part = String(limb)
            text += String(repeating: "0", count: 9 - part.count) + part
        }
        return text
    }

    public var description: String { (isNegative ? "-" : "") + digits }

    // MARK: Arithmetic

    public static prefix func - (value: BigInteger) -> BigInteger {
        BigInteger(isNegative: !value.isNegative, limbs: value.limbs)
    }

    public static func + (lhs: BigInteger, rhs: BigInteger) -> BigInteger {
        if lhs.isNegative == rhs.isNegative {
            return BigInteger(isNegative: lhs.isNegative, limbs: add(lhs.limbs, rhs.limbs))
        }
        if compareMagnitudes(lhs.limbs, rhs.limbs) >= 0 {
            return BigInteger(isNegative: lhs.isNegative, limbs: subtract(lhs.limbs, rhs.limbs))
        }
        return BigInteger(isNegative: rhs.isNegative, limbs: subtract(rhs.limbs, lhs.limbs))
    }

    public static func - (lhs: BigInteger, rhs: BigInteger) -> BigInteger { lhs + -rhs }

    public static func * (lhs: BigInteger, rhs: BigInteger) -> BigInteger {
        guard !lhs.isZero, !rhs.isZero else { return .zero }
        var product = [UInt64](repeating: 0, count: lhs.limbs.count + rhs.limbs.count + 1)
        for (i, a) in lhs.limbs.enumerated() {
            var carry: UInt64 = 0
            for (j, b) in rhs.limbs.enumerated() {
                let value = product[i + j] + UInt64(a) * UInt64(b) + carry
                product[i + j] = value % base
                carry = value / base
            }
            var k = i + rhs.limbs.count
            while carry > 0 {
                let value = product[k] + carry
                product[k] = value % base
                carry = value / base
                k += 1
            }
        }
        return BigInteger(isNegative: lhs.isNegative != rhs.isNegative, limbs: product.map { UInt32($0) })
    }

    public static func += (lhs: inout BigInteger, rhs: BigInteger) { lhs = lhs + rhs }
    public static func -= (lhs: inout BigInteger, rhs: BigInteger) { lhs = lhs - rhs }
    public static func *= (lhs: inout BigInteger, rhs: BigInteger) { lhs = lhs * rhs }

    /// Floor division and modulus by a positive `Int`, as XML Schema 1.1
    /// Part 2 defines ·div· and ·mod· (§D.1: "a ·div· b = ⌊a/b⌋", "a ·mod· b
    /// = a − (a ·div· b) × b").
    func floorDivided(by divisor: Int) -> (quotient: BigInteger, remainder: Int) {
        precondition(divisor > 0 && UInt64(divisor) < Self.base * 4)
        var quotient = [UInt32](repeating: 0, count: limbs.count)
        var remainder: UInt64 = 0
        for index in limbs.indices.reversed() {
            let value = remainder * Self.base + UInt64(limbs[index])
            quotient[index] = UInt32(value / UInt64(divisor))
            remainder = value % UInt64(divisor)
        }
        var result = BigInteger(isNegative: isNegative, limbs: quotient)
        var rest = Int(remainder)
        if isNegative && rest != 0 {
            result = result - BigInteger(1)
            rest = divisor - rest
        }
        return (result, rest)
    }

    /// The integer times 10ⁿ.
    func timesPowerOfTen(_ exponent: Int) -> BigInteger {
        guard exponent > 0, !isZero else { return self }
        let digits = self.digits + String(repeating: "0", count: exponent)
        return BigInteger(digits: digits, isNegative: isNegative)!
    }

    public static func < (lhs: BigInteger, rhs: BigInteger) -> Bool {
        if lhs.isNegative != rhs.isNegative { return lhs.isNegative }
        let order = compareMagnitudes(lhs.limbs, rhs.limbs)
        return lhs.isNegative ? order > 0 : order < 0
    }

    private static func compareMagnitudes(_ lhs: [UInt32], _ rhs: [UInt32]) -> Int {
        if lhs.count != rhs.count { return lhs.count < rhs.count ? -1 : 1 }
        for index in lhs.indices.reversed() where lhs[index] != rhs[index] {
            return lhs[index] < rhs[index] ? -1 : 1
        }
        return 0
    }

    private static func add(_ lhs: [UInt32], _ rhs: [UInt32]) -> [UInt32] {
        var result: [UInt32] = []
        var carry: UInt64 = 0
        for index in 0..<max(lhs.count, rhs.count) {
            let value = UInt64(index < lhs.count ? lhs[index] : 0) + UInt64(index < rhs.count ? rhs[index] : 0) + carry
            result.append(UInt32(value % base))
            carry = value / base
        }
        if carry > 0 { result.append(UInt32(carry)) }
        return result
    }

    /// `lhs − rhs` for magnitudes with `lhs ≥ rhs`.
    private static func subtract(_ lhs: [UInt32], _ rhs: [UInt32]) -> [UInt32] {
        var result: [UInt32] = []
        var borrow: Int64 = 0
        for index in lhs.indices {
            var value = Int64(lhs[index]) - borrow - Int64(index < rhs.count ? rhs[index] : 0)
            borrow = 0
            if value < 0 {
                value += Int64(base)
                borrow = 1
            }
            result.append(UInt32(value))
        }
        return result
    }
}
