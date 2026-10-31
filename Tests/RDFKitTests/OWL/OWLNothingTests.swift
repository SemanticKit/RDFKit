import Testing
import RDFKit

@Suite(.tags(.class, .owl))
struct OWLNothingTests {
    /// owl:Nothing, the empty class, is Never (D7): no value is a member.
    @Test func isNever() {
        #expect(ObjectIdentifier(OWL.Nothing.self) == ObjectIdentifier(Never.self))
    }
}
