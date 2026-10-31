import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDBase64BinaryTests {
    /// xsd:base64Binary's value is a finite sequence of octets (XSD 1.1
    /// Part 2 §3.3.16.1), and it is a literal, of a datatype other than
    /// xsd:hexBinary's.
    @Test func isAnOctetSequenceLiteral() {
        let octets = XSD.base64Binary([0x0F, 0xB7])
        #expect(octets.value == XSD.hexBinary([0x0F, 0xB7]).value)
        #expect((octets as Any) is RDFS.Literal)
        #expect(!((octets as Any) is XSD.hexBinary))
    }

    /// The lexical mapping of RFC 3548, on the forms the grammar
    /// `Base64Binary` gives: groups of four, padding at the end, and a
    /// single space after any character but the last (§3.3.16.2).
    @Test(arguments: [
        ("", [] as [UInt8]),
        ("D7c=", [0x0F, 0xB7]),
        ("Zg==", [0x66]),
        ("Zm8=", [0x66, 0x6F]),
        ("Zm9v", [0x66, 0x6F, 0x6F]),
        ("Zm9vYmFy", [0x66, 0x6F, 0x6F, 0x62, 0x61, 0x72]),
        ("Zm9v YmFy", [0x66, 0x6F, 0x6F, 0x62, 0x61, 0x72]),
        ("Z m 9 v", [0x66, 0x6F, 0x6F]),
        ("Zg= =", [0x66]),
        ("Z g = =", [0x66]),
        ("+/+/", [0xFB, 0xFF, 0xBF]),
    ])
    func mapsTheLexicalForm(_ lexicalForm: String, _ octets: [UInt8]) throws {
        #expect(try XSD.base64Binary(lexicalForm: lexicalForm).value == octets)
    }

    /// A form the grammar does not give is ill-typed: a length that is not
    /// a multiple of four, padding not at the end or too long, bits left
    /// over before the padding (`B16char`, `B04char`), a leading, trailing
    /// or double space, and any character outside the Base64 Alphabet.
    @Test(arguments: [
        "Zg", "Zg=", "Zm9", "Z===", "====", "Zg==Zg==", "Z=g=",
        "Zh==", "Zm9=", "D7d=",
        " Zm9v", "Zm9v ", "Zm  9v", "Zm9v\n", "Zm9v\tYmFy",
        "Zm9-", "Zm9_", "Zm9v!",
    ])
    func rejectsAFormOutsideTheLexicalSpace(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.base64Binary(lexicalForm: lexicalForm) }
    }

    /// The canonical mapping writes no whitespace and pads the last group
    /// (`Canonical-base64Binary`), and maps back to the value.
    @Test func hasACanonicalFormWithoutWhitespace() throws {
        #expect(XSD.base64Binary([0x0F, 0xB7]).canonicalForm == "D7c=")
        #expect(XSD.base64Binary([0x66]).canonicalForm == "Zg==")
        #expect(XSD.base64Binary([]).canonicalForm == "")
        #expect(try XSD.base64Binary(lexicalForm: "Zm9v YmFy").canonicalForm == "Zm9vYmFy")
        for count in 0...7 {
            let octets = XSD.base64Binary((0..<count).map { UInt8(truncatingIfNeeded: $0 &* 97 &+ 13) })
            #expect(try XSD.base64Binary(lexicalForm: octets.canonicalForm) == octets)
        }
    }
}
