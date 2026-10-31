import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFGeekcodeTests {
    /// foaf:geekcode, translated from index.rdf: its domain, FOAF.Person, is a class of FOAF, so it is a requirement of FOAF.Person.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Person, Values<any RDFS.Literal>> = \.geekcode
        _ = path
    }
}
