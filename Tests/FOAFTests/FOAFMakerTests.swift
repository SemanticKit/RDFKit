import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFMakerTests {
    /// foaf:maker, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Maker.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Maker, Values<any FOAF.Agent>> = \.maker
        _ = path
    }
}
