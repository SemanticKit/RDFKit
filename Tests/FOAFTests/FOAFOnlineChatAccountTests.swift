import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOnlineChatAccountTests {
    /// foaf:OnlineChatAccount rdfs:subClassOf FOAF.OnlineAccount, translated from index.rdf, as protocol
    /// inheritance: the upcasts compile only if a FOAF.OnlineChatAccount is each of these.
    @Test func inheritsItsSuperclasses() {
        let asFOAFOnlineAccount: (any FOAF.OnlineChatAccount) -> any FOAF.OnlineAccount = { $0 }
        let asRDFSResource: (any FOAF.OnlineChatAccount) -> any RDFS.Resource = { $0 }
        _ = (asFOAFOnlineAccount, asRDFSResource)
    }
}
