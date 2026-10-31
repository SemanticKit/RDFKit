import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDDoubleTests {
    /// xsd:double is IEEE double precision (XSD 1.1 Part 2 §3.3.5), exactly
    /// Swift's Double, so the datatype is Double (rule 20), and a Double is
    /// a literal.
    @Test func isDoubleAndALiteral() {
        let ratio: XSD.double = 0.5
        #expect(ratio == 0.5)
        #expect((0.5 as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.double.self) == ObjectIdentifier(Double.self))
    }
}
