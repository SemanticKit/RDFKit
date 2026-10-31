import Testing
import RDFKit

@Suite(.tags(.class, .rdf))
struct RDFPropertyTests {
    /// rdf:Property, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDF.Property)
        #expect(member is RDFS.Resource)
    }

    private final class Member: RDF.Property {}
}
