import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDUnsignedLongTests {
    /// xsd:unsignedLong is xsd:nonNegativeInteger with maxInclusive 18446744073709551615, beyond Int (XSD 1.1 Part 2 §3.4.21),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.unsignedLong(BigInteger(0)).value == BigInteger(0))
        #expect(try XSD.unsignedLong(BigInteger(Int.max) * BigInteger(2) + BigInteger(1)).value == BigInteger(Int.max) * BigInteger(2) + BigInteger(1))
        #expect((try XSD.unsignedLong(BigInteger(0)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:unsignedLong is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedLong(BigInteger(Int.max) * BigInteger(2) + BigInteger(2)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.unsignedLong(BigInteger(-1)) }
    }
}
