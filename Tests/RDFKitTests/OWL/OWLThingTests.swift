import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLThingTests {
    /// owl:Thing and rdfs:Resource are one root (D7).
    @Test func isTheRoot() {
        #expect(ObjectIdentifier((any OWL.Thing).self) == ObjectIdentifier((any RDFS.Resource).self))
    }
}
