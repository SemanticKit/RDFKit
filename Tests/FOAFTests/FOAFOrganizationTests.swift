import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOrganizationTests {
    /// foaf:Organization rdfs:subClassOf FOAF.Agent, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.Organization)
        #expect(member is FOAF.Agent)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.Organization {}
}
