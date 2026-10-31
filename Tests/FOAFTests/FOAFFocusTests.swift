import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFFocusTests {
    /// foaf:focus, translated from index.rdf: its domain, skos:Concept, is a
    /// class index.rdf declares, so it is a requirement of FOAF.Concept.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Concept, Values<any OWL.Thing>> = \.focus
        _ = path
    }
}
