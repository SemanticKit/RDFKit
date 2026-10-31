import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDStringTests {
    /// xsd:string is a Swift value type whose value is a String (D6), and a
    /// literal.
    @Test func isAValueTypeLiteral() {
        let name = XSD.string("Alice")
        #expect(name.value == "Alice")
        #expect(name == XSD.string("Alice"))
        #expect((name as Any) is RDFS.Literal)
    }
}
