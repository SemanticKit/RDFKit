import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLAnnotationTests {
    /// owl:Annotation, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.Annotation)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.Annotation {}
}
