import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDUnsignedShortTests {
    /// xsd:unsignedShort is xsd:unsignedInt with maxInclusive 65535 (XSD 1.1 Part 2 §3.4.23),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.unsignedShort(BigInteger(0)).value == BigInteger(0))
        #expect(try XSD.unsignedShort(BigInteger(65535)).value == BigInteger(65535))
        #expect((try XSD.unsignedShort(BigInteger(0)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:unsignedShort is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedShort(BigInteger(65536)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedShort(BigInteger(-1)) }
    }
}
