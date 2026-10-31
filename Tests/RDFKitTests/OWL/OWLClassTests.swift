import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLClassTests {
    /// owl:Class rdfs:subClassOf RDFS.Class, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.Class)
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.Class {}
}
