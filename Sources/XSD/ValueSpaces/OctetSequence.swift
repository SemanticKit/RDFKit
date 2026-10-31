/// The lexical and canonical mappings between lexical forms and finite
/// sequences of octets, `[UInt8]`: the value space of `xsd:hexBinary` and of
/// `xsd:base64Binary` (XML Schema 1.1 Part 2 §3.3.15.1 and §3.3.16.1: "the
/// set of finite-length sequences of zero or more binary octets. The length
/// of a value is the number of octets").
///
/// The value space is exactly a Swift `[UInt8]`: an array of octets is
/// finite, may be empty, and two are equal when their octets are, one by
/// one. It needs no Foundation, which the `XSD` module does not import.
///
/// The mappings read the lexical form as RDF gives it, with no whitespace
/// processing: RDF 1.2 Concepts maps a literal's lexical form, which a
/// leading or trailing space takes out of the lexical space.
enum OctetSequence {
    // MARK: - hexBinary (§3.3.15.2, §E.4)

    /// ·hexBinaryMap·: `([0-9a-fA-F]{2})*`, each ·hexOctet· an octet, the
    /// first digit its high four bits.
    static func hexBinaryMap(_ lexicalForm: String) throws(DatatypeError) -> [UInt8] {
        let digits = Array(lexicalForm.utf8)
        guard digits.count.isMultiple(of: 2) else { throw .illTyped }
        var octets: [UInt8] = []
        octets.reserveCapacity(digits.count / 2)
        var index = 0
        while index < digits.count {
            guard let high = hexDigitMap(digits[index]), let low = hexDigitMap(digits[index + 1]) else {
                throw .illTyped
            }
            octets.append(high << 4 | low)
            index += 2
        }
        return octets
    }

    /// ·hexDigitMap·: the number a ·hexDigit· denotes.
    private static func hexDigitMap(_ digit: UInt8) -> UInt8? {
        switch digit {
        case UInt8(ascii: "0")...UInt8(ascii: "9"): digit - UInt8(ascii: "0")
        case UInt8(ascii: "A")...UInt8(ascii: "F"): digit - UInt8(ascii: "A") + 10
        case UInt8(ascii: "a")...UInt8(ascii: "f"): digit - UInt8(ascii: "a") + 10
        default: nil
        }
    }

    /// ·hexBinaryCanonical·: two upper-case ·hexDigit·s per octet
    /// (·hexDigitCanonical·). XML Schema 1.1 Part 2 §E.4: "The ·canonical
    /// mapping· for hexBinary uses only the uppercase forms of A-F."
    static func hexBinaryCanonical(_ octets: [UInt8]) -> String {
        var digits: [UInt8] = []
        digits.reserveCapacity(octets.count * 2)
        for octet in octets {
            digits.append(hexDigits[Int(octet >> 4)])
            digits.append(hexDigits[Int(octet & 0x0F)])
        }
        return String(decoding: digits, as: UTF8.self)
    }

    private static let hexDigits = Array("0123456789ABCDEF".utf8)

    // MARK: - base64Binary (§3.3.16.2)

    /// The lexical mapping of base64Binary, "as given in [RFC 2045] and
    /// [RFC 3548]", on the lexical space the grammar `Base64Binary` gives:
    ///
    ///     Base64Binary ::= (B64quad* B64final)?
    ///     B64quad      ::= (B64 B64 B64 B64)
    ///     B64final     ::= B64finalquad | Padded16 | Padded8
    ///     B64finalquad ::= (B64 B64 B64 B64char)
    ///     Padded16     ::= B64 B64 B16 '='
    ///     Padded8      ::= B64 B04 '=' #x20? '='
    ///     B64 ::= B64char #x20?   B16 ::= B16char #x20?   B04 ::= B04char #x20?
    ///
    /// A space may follow any character but the last, never another space;
    /// without the spaces the form is groups of four characters with `=`
    /// only at the end, and the character before the padding leaves no bits
    /// over (`B16char`, `B04char`).
    static func base64BinaryMap(_ lexicalForm: String) throws(DatatypeError) -> [UInt8] {
        var characters: [UInt8] = []
        var afterCharacter = false
        for byte in lexicalForm.utf8 {
            if byte == UInt8(ascii: " ") {
                guard afterCharacter else { throw .illTyped }
                afterCharacter = false
            } else {
                characters.append(byte)
                afterCharacter = true
            }
        }
        guard characters.isEmpty || afterCharacter, characters.count.isMultiple(of: 4) else { throw .illTyped }
        let padding = characters.reversed().prefix { $0 == UInt8(ascii: "=") }.count
        guard padding <= 2 else { throw .illTyped }
        var octets: [UInt8] = []
        octets.reserveCapacity(characters.count / 4 * 3)
        var bits: UInt32 = 0
        var bitCount = 0
        for character in characters.dropLast(padding) {
            guard let sextet = base64Values[Int(character)] else { throw .illTyped }
            bits = bits << 6 | UInt32(sextet)
            bitCount += 6
            if bitCount >= 8 {
                bitCount -= 8
                octets.append(UInt8(truncatingIfNeeded: bits >> UInt32(bitCount)))
            }
        }
        // The bits left over are the padding's: B16char ends in '00', B04char
        // in '0000'.
        guard bits & (1 << UInt32(bitCount) - 1) == 0 else { throw .illTyped }
        return octets
    }

    /// The canonical mapping of base64Binary: "the encoding algorithm for
    /// Base64 data given in [RFC 2045] and [RFC 3548], with the proviso that
    /// no characters except those in the Base64 Alphabet are to be written
    /// out", the grammar `Canonical-base64Binary`.
    static func base64BinaryCanonical(_ octets: [UInt8]) -> String {
        var characters: [UInt8] = []
        characters.reserveCapacity((octets.count + 2) / 3 * 4)
        var index = 0
        while index < octets.count {
            let count = min(3, octets.count - index)
            var group: UInt32 = 0
            for offset in 0..<3 {
                group = group << 8 | (offset < count ? UInt32(octets[index + offset]) : 0)
            }
            for sextet in 0..<4 {
                if sextet <= count {
                    characters.append(base64Alphabet[Int(group >> UInt32(18 - 6 * sextet) & 0x3F)])
                } else {
                    characters.append(UInt8(ascii: "="))
                }
            }
            index += count
        }
        return String(decoding: characters, as: UTF8.self)
    }

    /// The Base64 Alphabet of RFC 3548 §3, in the order of its values.
    private static let base64Alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8)

    /// The value of each byte in the alphabet, `nil` for the others.
    private static let base64Values: [UInt8?] = {
        var values = [UInt8?](repeating: nil, count: 256)
        for (value, character) in base64Alphabet.enumerated() {
            values[Int(character)] = UInt8(value)
        }
        return values
    }()
}
