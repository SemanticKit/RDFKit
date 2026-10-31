import Testing
import RDFKit

@Suite(.tags(.class, .rdfs))
struct RDFSContainerTests {
    /// rdfs:Container, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDFS.Container)
        #expect(member is RDFS.Resource)
    }

    private final class Member: RDFS.Container {}
}
