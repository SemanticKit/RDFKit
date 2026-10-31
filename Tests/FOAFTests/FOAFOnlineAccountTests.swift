import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOnlineAccountTests {
    /// foaf:OnlineAccount rdfs:subClassOf OWL.Thing, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.OnlineAccount)
        #expect(member is OWL.Thing)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.OnlineAccount {}
}
