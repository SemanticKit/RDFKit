import RDFCore

/// `xsd:decimal` (XML Schema 1.1 Part 2 §3.3.3): the decimal numbers, and
/// through restriction the integers and their ranges.
extension decimal {
    public typealias Value = DecimalNumber

    /// ·decimalLexicalMap·, for decimalLexicalRep:
    /// `(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)`.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> DecimalNumber {
        var numeral = Substring(lexicalForm)
        let isNegative = numeral.hasPrefix("-")
        if isNegative || numeral.hasPrefix("+") { numeral = numeral.dropFirst() }
        guard numeral.allSatisfy({ $0 == "." || ($0.isASCII && $0.isNumber) }),
              let value = DecimalNumber(unsignedNumeral: numeral, isNegative: isNegative) else { throw .illTyped }
        return value
    }

    /// ·decimalCanonicalMap·: no decimal point for an integer.
    public static func representations(of value: DecimalNumber) -> [String] {
        [value.description]
    }
}

extension DecimalNumber: FacetMeasurable {
    public var facetDigits: (total: Int, fraction: Int)? { (totalDigitCount, fractionDigitCount) }
}

extension integer: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        // Every Int is an integer.
        try! self.init(DecimalNumber(value))
    }
}
