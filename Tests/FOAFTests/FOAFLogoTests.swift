import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFLogoTests {
    /// foaf:logo, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Logo.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Logo, Values<any OWL.Thing>> = \.logo
        _ = path
    }
}
