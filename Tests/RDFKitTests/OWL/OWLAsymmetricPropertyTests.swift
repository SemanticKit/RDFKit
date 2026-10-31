import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAsymmetricPropertyTests {
    /// owl:AsymmetricProperty rdfs:subClassOf OWL.ObjectProperty, RDF.Property, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.AsymmetricProperty)
        #expect(member is OWL.ObjectProperty)
        #expect(member is RDF.Property)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.AsymmetricProperty {}
}
