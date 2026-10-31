import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFMembershipClassTests {
    /// foaf:membershipClass, translated from index.rdf: its domain is the root, so it is its own protocol, FOAF.MembershipClass.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.MembershipClass, Values<any RDFS.Resource>> = \.membershipClass
        _ = path
    }
}
