import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFGroupTests {
    /// foaf:Group rdfs:subClassOf FOAF.Agent, translated from index.rdf, as protocol inheritance:
    /// a FOAF.Group is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asFOAFAgent: (any FOAF.Group) -> any FOAF.Agent = { $0 }
        let asRDFSResource: (any FOAF.Group) -> any RDFS.Resource = { $0 }
        _ = (asFOAFAgent, asRDFSResource)
    }
}
