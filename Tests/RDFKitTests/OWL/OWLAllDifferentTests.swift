import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAllDifferentTests {
    /// owl:AllDifferent, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.AllDifferent)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.AllDifferent {}
}
