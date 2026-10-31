import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLOntologyTests {
    /// owl:Ontology, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.Ontology)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.Ontology {}
}
