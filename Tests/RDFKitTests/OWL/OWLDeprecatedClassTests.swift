import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLDeprecatedClassTests {
    /// owl:DeprecatedClass rdfs:subClassOf RDFS.Class, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is OWL.DeprecatedClass)
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    private final class Member: OWL.DeprecatedClass {}
}
