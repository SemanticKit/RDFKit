import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFKnowsTests {
    /// foaf:knows, translated from index.rdf: its domain, foaf:Person, is a class of FOAF, so it is a requirement of FOAF.Person, and its range, foaf:Person, types its values. The key path
    /// compiles only if the requirement exists with that type (D4, D5).
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Person, Values<any FOAF.Person>> = \.knows
        _ = path
    }
}
