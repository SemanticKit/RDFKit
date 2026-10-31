import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFPhoneTests {
    /// foaf:phone, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.Phone.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.Phone, Values<any RDFS.Resource>> = \.phone
        _ = path
    }
}
