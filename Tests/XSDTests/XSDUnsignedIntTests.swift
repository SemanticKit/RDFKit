import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDUnsignedIntTests {
    /// xsd:unsignedInt is xsd:unsignedLong with maxInclusive 4294967295 (XSD 1.1 Part 2 §3.4.22),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.unsignedInt(BigInteger(0)).value == BigInteger(0))
        #expect(try XSD.unsignedInt(BigInteger(4294967295)).value == BigInteger(4294967295))
        #expect((try XSD.unsignedInt(BigInteger(0)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:unsignedInt is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedInt(BigInteger(4294967296)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedInt(BigInteger(-1)) }
    }
}
