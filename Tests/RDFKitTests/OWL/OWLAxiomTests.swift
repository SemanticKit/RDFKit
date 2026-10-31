import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAxiomTests {
    /// owl:Axiom, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.Axiom)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.Axiom {}
}
