import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFProjectTests {
    /// foaf:Project, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.Project)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.Project {}
}
