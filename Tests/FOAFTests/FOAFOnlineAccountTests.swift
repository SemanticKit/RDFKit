import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOnlineAccountTests {
    /// foaf:OnlineAccount rdfs:subClassOf OWL.Thing, translated from index.rdf, as protocol inheritance:
    /// a FOAF.OnlineAccount is each of these, which the upcasts compile only if so.
    @Test func inheritsItsSuperclasses() {
        let asOWLThing: (any FOAF.OnlineAccount) -> any OWL.Thing = { $0 }
        let asRDFSResource: (any FOAF.OnlineAccount) -> any RDFS.Resource = { $0 }
        _ = (asOWLThing, asRDFSResource)
    }
}
