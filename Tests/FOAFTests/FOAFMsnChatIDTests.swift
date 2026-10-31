import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFMsnChatIDTests {
    /// foaf:msnChatID, translated from index.rdf: its domain, FOAF.Agent, is a class of FOAF, so it is a requirement of FOAF.Agent.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Agent, Values<any RDFS.Literal>> = \.msnChatID
        _ = path
    }
}
