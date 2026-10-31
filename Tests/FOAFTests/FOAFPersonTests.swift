import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFPersonTests {
    /// foaf:Person rdfs:subClassOf FOAF.Agent, FOAF.SpatialThing, translated from index.rdf, as protocol inheritance.
    @Test func inheritsItsSuperclasses() {
        let member: AnyObject = Member()
        #expect(member is FOAF.Person)
        #expect(member is FOAF.Agent)
        #expect(member is FOAF.SpatialThing)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.Person {
        var knows: Values<any FOAF.Person> = []
    }
}
