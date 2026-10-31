import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFSpatialThingTests {
    /// geo:SpatialThing, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.SpatialThing)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.SpatialThing {}
}
