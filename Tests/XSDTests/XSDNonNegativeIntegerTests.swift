import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDNonNegativeIntegerTests {
    /// xsd:nonNegativeInteger is xsd:integer with minInclusive 0 (XSD 1.1 Part 2 §3.4.20),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.nonNegativeInteger(BigInteger(0)).value == BigInteger(0))
        #expect(try XSD.nonNegativeInteger(BigInteger(5)).value == BigInteger(5))
        #expect((try XSD.nonNegativeInteger(BigInteger(0)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:nonNegativeInteger is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.nonNegativeInteger(BigInteger(-1)) }
    }
}
