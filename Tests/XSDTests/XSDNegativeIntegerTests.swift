import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDNegativeIntegerTests {
    /// xsd:negativeInteger is xsd:nonPositiveInteger with maxInclusive -1 (XSD 1.1 Part 2 §3.4.15),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.negativeInteger(BigInteger(-1)).value == BigInteger(-1))
        #expect((try XSD.negativeInteger(BigInteger(-1)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:negativeInteger is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.negativeInteger(BigInteger(0)) }
    }
}
