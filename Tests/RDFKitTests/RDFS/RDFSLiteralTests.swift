import Testing
import RDFKit

@Suite(.tags(.class, .rdfs))
struct RDFSLiteralTests {
    /// rdfs:Literal, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDFS.Literal)
        #expect(member is RDFS.Resource)
    }

    /// A literal is a Swift value type (D6), and rdfs:Literal rdfs:subClassOf
    /// rdfs:Resource holds for it.
    @Test func aValueTypeIsALiteral() {
        let literal: Any = Text(value: "Alice")
        #expect(literal is RDFS.Literal)
        #expect(literal is RDFS.Resource)
    }

    private final class Member: RDFS.Literal {}

    private struct Text: RDFS.Literal {
        let value: String
    }
}
