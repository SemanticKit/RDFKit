import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFGivenNameTests {
    /// foaf:givenName, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.GivenName.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.GivenName, Values<any RDFS.Resource>> = \.givenName
        _ = path
    }
}
