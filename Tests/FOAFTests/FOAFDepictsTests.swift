import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFDepictsTests {
    /// foaf:depicts, translated from index.rdf: its domain, FOAF.Image, is a class of FOAF, so it is a requirement of FOAF.Image.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Image, Values<any OWL.Thing>> = \.depicts
        _ = path
    }
}
