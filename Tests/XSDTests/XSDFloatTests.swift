import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDFloatTests {
    /// xsd:float is IEEE single precision (XSD 1.1 Part 2 §3.3.4), exactly
    /// Swift's Float, so the datatype is Float (rule 20), and a Float is a
    /// literal.
    @Test func isFloatAndALiteral() {
        let ratio: XSD.float = 0.5
        #expect(ratio == 0.5)
        #expect((Float(0.5) as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.float.self) == ObjectIdentifier(Float.self))
    }
}
