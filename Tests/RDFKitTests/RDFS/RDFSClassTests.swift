import Testing
import RDFKit

@Suite(.tags(.class, .rdfs))
struct RDFSClassTests {
    /// rdfs:Class, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    /// A class's members are individuals, so its protocol is class-bound
    /// and members compare by identity through it (D3).
    @Test func membersCompareByIdentity() {
        let first: any RDFS.Class = Member()
        let second: any RDFS.Class = Member()
        #expect(first === first)
        #expect(first !== second)
    }

    private final class Member: RDFS.Class {}
}
