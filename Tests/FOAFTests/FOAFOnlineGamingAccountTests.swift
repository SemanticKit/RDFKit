import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFOnlineGamingAccountTests {
    /// foaf:OnlineGamingAccount rdfs:subClassOf FOAF.OnlineAccount, translated from index.rdf, as protocol
    /// inheritance: the upcasts compile only if a FOAF.OnlineGamingAccount is each of these.
    @Test func inheritsItsSuperclasses() {
        let asFOAFOnlineAccount: (any FOAF.OnlineGamingAccount) -> any FOAF.OnlineAccount = { $0 }
        let asRDFSResource: (any FOAF.OnlineGamingAccount) -> any RDFS.Resource = { $0 }
        _ = (asFOAFOnlineAccount, asRDFSResource)
    }
}
