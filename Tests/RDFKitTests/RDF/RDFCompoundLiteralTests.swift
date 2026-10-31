import Testing
import RDFCore
import RDFKit

@Suite(.tags(.class, .rdf))
struct RDFCompoundLiteralTests {
    /// rdf:CompoundLiteral, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDF.CompoundLiteral)
        #expect(member is RDFS.Resource)
    }

    private final class Member: RDF.CompoundLiteral {
        var language: Values<any RDFS.Resource> = []
        var direction: Values<any RDFS.Resource> = []
    }
}
