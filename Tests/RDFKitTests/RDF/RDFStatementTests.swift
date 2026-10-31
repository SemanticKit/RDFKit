import Testing
import RDFKit

@Suite(.tags(.class, .rdf))
struct RDFStatementTests {
    /// rdf:Statement, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDF.Statement)
        #expect(member is RDFS.Resource)
    }

    private final class Member: RDF.Statement {}
}
