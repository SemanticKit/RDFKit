import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAllDisjointPropertiesTests {
    /// owl:AllDisjointProperties, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.AllDisjointProperties)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.AllDisjointProperties {}
}
