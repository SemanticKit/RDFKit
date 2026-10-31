import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAllDisjointClassesTests {
    /// owl:AllDisjointClasses, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.AllDisjointClasses)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.AllDisjointClasses {}
}
