import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDBooleanTests {
    /// xsd:boolean is a Swift value type whose value is a Bool (D6), and a
    /// literal.
    @Test func isAValueTypeLiteral() {
        let flag = XSD.boolean(true)
        #expect(flag.value)
        #expect(flag != XSD.boolean(false))
        #expect((flag as Any) is RDFS.Literal)
    }
}
