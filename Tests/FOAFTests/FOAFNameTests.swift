import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFNameTests {
    /// foaf:name, translated from index.rdf: its domain is owl:Thing, the root, so it is its own protocol, FOAF.Name, and its values are literals. The key path
    /// compiles only if the requirement exists with that type (D4, D5).
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Name, Values<any RDFS.Literal>> = \.name
        _ = path
    }
}
