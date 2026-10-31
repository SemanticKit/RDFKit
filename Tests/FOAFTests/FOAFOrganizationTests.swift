import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOrganizationTests {
    /// foaf:Organization rdfs:subClassOf FOAF.Agent, translated from index.rdf, as protocol inheritance:
    /// a FOAF.Organization is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asFOAFAgent: (any FOAF.Organization) -> any FOAF.Agent = { $0 }
        let asRDFSResource: (any FOAF.Organization) -> any RDFS.Resource = { $0 }
        _ = (asFOAFAgent, asRDFSResource)
    }
}
