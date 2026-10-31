import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFAgentTests {
    /// foaf:Agent, translated from index.rdf, as protocol inheritance:
    /// a FOAF.Agent is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asRDFSResource: (any FOAF.Agent) -> any RDFS.Resource = { $0 }
        _ = (asRDFSResource)
    }
}
