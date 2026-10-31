import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDUnsignedByteTests {
    /// xsd:unsignedByte is xsd:unsignedShort with maxInclusive 255 (XSD 1.1 Part 2 §3.4.24),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.unsignedByte(BigInteger(0)).value == BigInteger(0))
        #expect(try XSD.unsignedByte(BigInteger(255)).value == BigInteger(255))
        #expect((try XSD.unsignedByte(BigInteger(0)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:unsignedByte is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedByte(BigInteger(256)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedByte(BigInteger(-1)) }
    }
}
