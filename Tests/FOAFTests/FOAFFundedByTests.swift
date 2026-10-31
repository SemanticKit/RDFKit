import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFFundedByTests {
    /// foaf:fundedBy, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.FundedBy.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.FundedBy, Values<any OWL.Thing>> = \.fundedBy
        _ = path
    }
}
