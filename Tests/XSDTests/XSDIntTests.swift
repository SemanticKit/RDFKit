import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDIntTests {
    /// xsd:int is xsd:long from -2147483648 to 2147483647 (XSD 1.1 Part 2 §3.4.17),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.int(BigInteger(2147483647)).value == BigInteger(2147483647))
        #expect(try XSD.int(BigInteger(-2147483648)).value == BigInteger(-2147483648))
        #expect((try XSD.int(BigInteger(2147483647)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:int is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.int(BigInteger(2147483648)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.int(BigInteger(-2147483649)) }
    }
}
