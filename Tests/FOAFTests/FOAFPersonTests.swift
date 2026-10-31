import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFPersonTests {
    /// foaf:Person rdfs:subClassOf FOAF.Agent, FOAF.SpatialThing, translated from index.rdf, as protocol inheritance:
    /// a FOAF.Person is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asFOAFAgent: (any FOAF.Person) -> any FOAF.Agent = { $0 }
        let asFOAFSpatialThing: (any FOAF.Person) -> any FOAF.SpatialThing = { $0 }
        let asRDFSResource: (any FOAF.Person) -> any RDFS.Resource = { $0 }
        _ = (asFOAFAgent, asFOAFSpatialThing, asRDFSResource)
    }
}
