import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFBased_nearTests {
    /// foaf:based_near, translated from index.rdf: its domain, FOAF.SpatialThing, is a class of FOAF, so it is a requirement of FOAF.SpatialThing.
    /// The key path compiles only if the requirement exists with its type.
    @Test func isARequirementTypedByItsRange() {
        let path: WritableKeyPath<any FOAF.SpatialThing, Values<any FOAF.SpatialThing>> = \.based_near
        _ = path
    }
}
