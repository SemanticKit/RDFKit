import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDIntegerTests {
    /// xsd:integer is derived from xsd:decimal, and its values are the
    /// unbounded integers (XSD 1.1 Part 2 §3.4.13), not bounded by Int (D6).
    @Test func isAnUnboundedValueTypeLiteral() {
        let count = XSD.integer(BigInteger(Int.max) + BigInteger(1))
        #expect(count.value > BigInteger(Int.max))
        #expect((count as Any) is RDFS.Literal)
    }
}
