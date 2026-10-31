import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDIntegerTests {
    /// xsd:integer is derived from xsd:decimal, and its values are the
    /// unbounded integers (XSD 1.1 Part 2 §3.4.13), not bounded by Int (D6).
    @Test func isAnUnboundedValueTypeLiteral() {
        let count = XSD.integer(BigInteger(Int.max) + BigInteger(1))
        #expect(count.value > BigInteger(Int.max))
        #expect((count as Any) is RDFS.Literal)
    }

    /// xsd:integer's lexical mapping is xsd:decimal's (§3.4.13.2) on the
    /// lexical space its pattern `[\-+]?[0-9]+` gives, after whiteSpace
    /// collapse.
    @Test func mapsALexicalForm() throws {
        #expect(try XSD.integer(lexicalForm: " +042\n").value == BigInteger(42))
        #expect(try XSD.integer(lexicalForm: "-0").value == BigInteger(0))
        #expect(try XSD.integer(lexicalForm: "-9223372036854775809").value == -BigInteger(Int.max) - BigInteger(2))
        for form in ["1.0", "1.", ".0", "1e2", "", "+", "1 2", "0x1"] {
            #expect(throws: DatatypeError.illTyped) { try XSD.integer(lexicalForm: form) }
        }
    }
}
