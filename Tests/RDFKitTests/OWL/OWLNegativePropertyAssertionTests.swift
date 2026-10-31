import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLNegativePropertyAssertionTests {
    /// owl:NegativePropertyAssertion, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.NegativePropertyAssertion)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.NegativePropertyAssertion {}
}
