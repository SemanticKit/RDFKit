import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAnnotationPropertyTests {
    /// owl:AnnotationProperty rdfs:subClassOf RDF.Property, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.AnnotationProperty)
        #expect(member is RDF.Property)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.AnnotationProperty {}
}
