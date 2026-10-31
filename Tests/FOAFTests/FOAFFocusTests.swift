import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFFocusTests {
    /// foaf:focus, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Focus.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Focus, Values<any OWL.Thing>> = \.focus
        _ = path
    }
}
