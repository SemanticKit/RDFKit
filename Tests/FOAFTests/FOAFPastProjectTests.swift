import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFPastProjectTests {
    /// foaf:pastProject, translated from index.rdf: its domain, FOAF.Person, is a class of FOAF, so it is a requirement of FOAF.Person.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Person, Values<any OWL.Thing>> = \.pastProject
        _ = path
    }
}
