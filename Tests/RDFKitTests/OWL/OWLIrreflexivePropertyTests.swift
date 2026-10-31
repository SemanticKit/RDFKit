import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLIrreflexivePropertyTests {
    /// owl:IrreflexiveProperty rdfs:subClassOf OWL.ObjectProperty, RDF.Property, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.IrreflexiveProperty)
        #expect(member is OWL.ObjectProperty)
        #expect(member is RDF.Property)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.IrreflexiveProperty {}
}
