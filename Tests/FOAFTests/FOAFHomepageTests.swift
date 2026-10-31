import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFHomepageTests {
    /// foaf:homepage, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Homepage.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Homepage, Values<any FOAF.Document>> = \.homepage
        _ = path
    }
}
