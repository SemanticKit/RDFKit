import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFTitleTests {
    /// foaf:title, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Title.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Title, Values<any RDFS.Resource>> = \.title
        _ = path
    }
}
