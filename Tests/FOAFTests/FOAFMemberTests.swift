import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFMemberTests {
    /// foaf:member, translated from index.rdf: its domain, FOAF.Group, is a class of FOAF, so it is a requirement of FOAF.Group.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Group, Values<any FOAF.Agent>> = \.member
        _ = path
    }
}
