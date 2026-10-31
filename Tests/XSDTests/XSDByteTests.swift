import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDByteTests {
    /// xsd:byte is xsd:short from -128 to 127 (XSD 1.1 Part 2 §3.4.19),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.byte(BigInteger(127)).value == BigInteger(127))
        #expect(try XSD.byte(BigInteger(-128)).value == BigInteger(-128))
        #expect((try XSD.byte(BigInteger(127)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:byte is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.byte(BigInteger(128)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.byte(BigInteger(-129)) }
    }
}
