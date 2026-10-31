import Testing
import RDFKit

@Suite(.tags(.class, .rdfs))
struct RDFSDatatypeTests {
    /// rdfs:Datatype rdfs:subClassOf RDFS.Class, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is RDFS.Datatype)
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    private final class Member: RDFS.Datatype {}
}
