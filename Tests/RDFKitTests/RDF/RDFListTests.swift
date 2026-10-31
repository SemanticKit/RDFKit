import Testing
import RDFKit

@Suite(.tags(.class, .rdf))
struct RDFListTests {
    /// rdf:List, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDF.List)
        #expect(member is RDFS.Resource)
    }

    private final class Member: RDF.List {}
}
