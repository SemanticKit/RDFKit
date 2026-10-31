import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOnlineEcommerceAccountTests {
    /// foaf:OnlineEcommerceAccount rdfs:subClassOf FOAF.OnlineAccount, translated from index.rdf, as protocol
    /// inheritance: the upcasts compile only if a FOAF.OnlineEcommerceAccount is each of these.
    @Test func inheritsItsSuperclasses() {
        let asFOAFOnlineAccount: (any FOAF.OnlineEcommerceAccount) -> any FOAF.OnlineAccount = { $0 }
        let asRDFSResource: (any FOAF.OnlineEcommerceAccount) -> any RDFS.Resource = { $0 }
        _ = (asFOAFOnlineAccount, asRDFSResource)
    }
}
