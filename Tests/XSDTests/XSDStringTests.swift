import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDStringTests {
    /// xsd:string's value space is exactly Swift's String, so the datatype
    /// is String (rule 20), and a String is a literal.
    @Test func isStringAndALiteral() {
        let name: XSD.string = "Alice"
        #expect(name == "Alice")
        #expect(("Alice" as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.string.self) == ObjectIdentifier(String.self))
    }
}
