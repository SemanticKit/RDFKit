import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLRestrictionTests {
    /// owl:Restriction rdfs:subClassOf OWL.Class, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.Restriction)
        #expect(member is OWL.Class)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.Restriction {}
}
