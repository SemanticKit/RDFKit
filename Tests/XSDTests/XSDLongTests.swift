import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDLongTests {
    /// xsd:long is xsd:integer from -9223372036854775808 to 9223372036854775807 (XSD 1.1 Part 2 §3.4.16),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.long(BigInteger(Int.max)).value == BigInteger(Int.max))
        #expect(try XSD.long(BigInteger(Int.min)).value == BigInteger(Int.min))
        #expect((try XSD.long(BigInteger(Int.max)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:long is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.long(BigInteger(Int.max) + BigInteger(1)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.long(BigInteger(Int.min) - BigInteger(1)) }
    }
}
