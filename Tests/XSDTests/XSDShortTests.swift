import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDShortTests {
    /// xsd:short is xsd:int from -32768 to 32767 (XSD 1.1 Part 2 §3.4.18),
    /// as derived.nxsd gives it; its values are xsd:integer's.
    @Test func acceptsItsValues() throws {
        #expect(try XSD.short(BigInteger(32767)).value == BigInteger(32767))
        #expect(try XSD.short(BigInteger(-32768)).value == BigInteger(-32768))
        #expect((try XSD.short(BigInteger(32767)) as Any) is RDFS.Literal)
    }

    /// A BigInteger outside the value space of xsd:short is ill-typed.
    @Test func throwsOutsideItsValueSpace() {
        #expect(throws: DatatypeError.illTyped) { try XSD.short(BigInteger(32768)) }
        #expect(throws: DatatypeError.illTyped) { try XSD.short(BigInteger(-32769)) }
    }
}
