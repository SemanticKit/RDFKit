import Testing
import RDFKit
import XSD

@Suite(.tags(.xsd))
struct XSDBooleanTests {
    /// xsd:boolean's value space is {true, false} (XSD 1.1 Part 2 §3.3.2),
    /// exactly Swift's Bool, so the datatype is Bool (rule 20), and a Bool
    /// is a literal.
    @Test func isBoolAndALiteral() {
        let flag: XSD.boolean = true
        #expect(flag)
        #expect((false as Any) is RDFS.Literal)
        #expect(ObjectIdentifier(XSD.boolean.self) == ObjectIdentifier(Bool.self))
    }
}
