import RDFCore

/// `xsd:hexBinary` (XML Schema 1.1 Part 2 §3.3.15): finite sequences of
/// octets, two hexadecimal digits each.
extension hexBinary {
    public typealias Value = [UInt8]

    /// ·hexBinaryMap·, for hexBinary: `([0-9a-fA-F]{2})*`.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> [UInt8] {
        let digits = Array(lexicalForm.unicodeScalars)
        guard digits.count.isMultiple(of: 2) else { throw .illTyped }
        var octets: [UInt8] = []
        for index in stride(from: 0, to: digits.count, by: 2) {
            guard let high = hexValue(digits[index]), let low = hexValue(digits[index + 1]) else { throw .illTyped }
            octets.append(high << 4 | low)
        }
        return octets
    }

    /// ·hexBinaryCanonical·: upper-case digits.
    public static func representations(of value: [UInt8]) -> [String] {
        let digits = Array("0123456789ABCDEF")
        return [String(value.flatMap { [digits[Int($0 >> 4)], digits[Int($0 & 0xF)]] })]
    }

    private static func hexValue(_ scalar: Unicode.Scalar) -> UInt8? {
        switch scalar {
        case "0"..."9": UInt8(scalar.value - 0x30)
        case "a"..."f": UInt8(scalar.value - 0x61 + 10)
        case "A"..."F": UInt8(scalar.value - 0x41 + 10)
        default: nil
        }
    }
}

/// `xsd:base64Binary` (§3.3.16): finite sequences of octets in the Base64
/// encoding of RFC 2045, with single spaces allowed between characters.
extension base64Binary {
    public typealias Value = [UInt8]

    private static let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".unicodeScalars)

    /// The lexical mapping, for the Base64Binary production:
    ///
    ///     Base64Binary  ::= (B64quad* B64final)?
    ///     B64final      ::= B64finalquad | Padded16 | Padded8
    ///     Padded16      ::= B64 B64 B16 '='
    ///     Padded8       ::= B64 B8 '=' #x20? '='
    ///     B64           ::= B64char #x20?
    ///     B16char       ::= [AEIMQUYcgkosw048]
    ///     B8char        ::= [AQgw]
    ///
    /// A space may follow any character but the last, never another space.
    public static func lexicalMapping(_ lexicalForm: String) throws(DatatypeError) -> [UInt8] {
        var characters: [Unicode.Scalar] = []
        var previousWasSpace = true
        for scalar in lexicalForm.unicodeScalars {
            if scalar == " " {
                guard !previousWasSpace else { throw .illTyped }
                previousWasSpace = true
            } else {
                characters.append(scalar)
                previousWasSpace = false
            }
        }
        guard !(previousWasSpace && !characters.isEmpty), characters.count.isMultiple(of: 4) else { throw .illTyped }
        let padding = characters.reversed().prefix { $0 == "=" }.count
        guard padding <= 2 else { throw .illTyped }
        var values: [UInt32] = []
        for scalar in characters.dropLast(padding) {
            guard let index = alphabet.firstIndex(of: scalar) else { throw .illTyped }
            values.append(UInt32(index))
        }
        // The last character before padding leaves no bits unused (B16char, B8char).
        if padding == 1, let last = values.last, last & 0b11 != 0 { throw .illTyped }
        if padding == 2, let last = values.last, last & 0b1111 != 0 { throw .illTyped }
        var octets: [UInt8] = []
        var buffer: UInt32 = 0
        var bits = 0
        for value in values {
            buffer = buffer << 6 | value
            bits += 6
            if bits >= 8 {
                bits -= 8
                octets.append(UInt8((buffer >> UInt32(bits)) & 0xFF))
            }
        }
        return octets
    }

    /// The canonical representation: the encoding with no spaces.
    public static func representations(of value: [UInt8]) -> [String] {
        var text = String.UnicodeScalarView()
        for start in stride(from: 0, to: value.count, by: 3) {
            let chunk = value[start..<min(start + 3, value.count)]
            var buffer: UInt32 = 0
            for octet in chunk { buffer = buffer << 8 | UInt32(octet) }
            buffer <<= UInt32(8 * (3 - chunk.count))
            for position in 0..<4 {
                if position <= chunk.count {
                    text.append(alphabet[Int((buffer >> UInt32(18 - 6 * position)) & 0x3F)])
                } else {
                    text.append("=")
                }
            }
        }
        return [String(text)]
    }
}

extension [UInt8]: FacetMeasurable {
    /// The number of octets, the measure the length facets constrain for
    /// binary data (§4.3.1).
    public var facetLength: Int? { count }
}
