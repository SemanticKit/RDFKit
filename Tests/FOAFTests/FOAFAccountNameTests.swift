import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFAccountNameTests {
    /// foaf:accountName, translated from index.rdf: its domain, FOAF.OnlineAccount, is a class of FOAF, so it is a requirement of FOAF.OnlineAccount.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.OnlineAccount, Values<any RDFS.Literal>> = \.accountName
        _ = path
    }
}
