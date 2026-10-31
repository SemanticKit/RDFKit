import Testing
import RDFKit

@Suite(.tags(.class, .rdfs))
struct RDFSResourceTests {
    /// An individual is an instance of a generated class, and its identity is
    /// the object's (D3).
    @Test func individualIdentityIsObjectIdentity() {
        let first = Member()
        let second = Member()
        #expect(first === first)
        #expect(first !== second)
    }

    private final class Member: RDFS.Resource {}
}
