import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDFloatTests {
    /// xsd:float is IEEE single precision (XSD 1.1 Part 2 §3.3.4), Swift's
    /// Float (D6), and a literal.
    @Test func isAValueTypeLiteral() {
        let ratio = XSD.float(0.5)
        #expect(ratio.value == 0.5)
        #expect((ratio as Any) is RDFS.Literal)
    }
}
