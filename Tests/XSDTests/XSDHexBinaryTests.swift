import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDHexBinaryTests {
    /// xsd:hexBinary's value is a finite sequence of octets (XSD 1.1 Part 2
    /// §3.3.15.1), and it is a literal.
    @Test func isAnOctetSequenceLiteral() {
        let octets = XSD.hexBinary([0x0F, 0xB7])
        #expect(octets.value == [0x0F, 0xB7])
        #expect(octets == XSD.hexBinary([0x0F, 0xB7]))
        #expect((octets as Any) is RDFS.Literal)
    }

    /// ·hexBinaryMap·: two hex digits per octet, either case (§3.3.15.2).
    @Test(arguments: [
        ("0FB7", [0x0F, 0xB7] as [UInt8]),
        ("0fb7", [0x0F, 0xB7]),
        ("", []),
        ("00FF7a", [0x00, 0xFF, 0x7A]),
    ])
    func mapsTheLexicalForm(_ lexicalForm: String, _ octets: [UInt8]) throws {
        #expect(try XSD.hexBinary(lexicalForm: lexicalForm).value == octets)
    }

    /// A form outside `([0-9a-fA-F]{2})*` is ill-typed: no whitespace
    /// processing, an odd number of digits, or a character that is not a
    /// hex digit.
    @Test(arguments: ["0", "0FB", "0G", " 0F", "0F ", "0F B7", "0x0F", "\u{FF26}0"])
    func rejectsAFormOutsideTheLexicalSpace(_ lexicalForm: String) {
        #expect(throws: DatatypeError.illTyped) { try XSD.hexBinary(lexicalForm: lexicalForm) }
    }

    /// ·hexBinaryCanonical· writes upper-case digits, and maps back to the
    /// value.
    @Test func hasAnUpperCaseCanonicalForm() throws {
        #expect(XSD.hexBinary([0x0F, 0xB7]).canonicalForm == "0FB7")
        #expect(XSD.hexBinary([]).canonicalForm == "")
        #expect(try XSD.hexBinary(lexicalForm: "0fb7").canonicalForm == "0FB7")
        let every = XSD.hexBinary((0...255).map(UInt8.init))
        #expect(try XSD.hexBinary(lexicalForm: every.canonicalForm) == every)
    }
}
