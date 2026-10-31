import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFThemeTests {
    /// foaf:theme, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Theme.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Theme, Values<any OWL.Thing>> = \.theme
        _ = path
    }
}
