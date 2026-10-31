import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFNickTests {
    /// foaf:nick, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Nick.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Nick, Values<any RDFS.Resource>> = \.nick
        _ = path
    }
}
