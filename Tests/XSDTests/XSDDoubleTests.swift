import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDoubleTests {
    /// xsd:double is IEEE double precision (XSD 1.1 Part 2 §3.3.5), Swift's
    /// Double (D6), and a literal.
    @Test func isAValueTypeLiteral() {
        let ratio = XSD.double(0.5)
        #expect(ratio.value == 0.5)
        #expect((ratio as Any) is RDFS.Literal)
    }
}
