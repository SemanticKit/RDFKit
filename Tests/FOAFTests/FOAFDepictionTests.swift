import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFDepictionTests {
    /// foaf:depiction, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Depiction.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Depiction, Values<any FOAF.Image>> = \.depiction
        _ = path
    }
}
