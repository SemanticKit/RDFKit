import Testing
import RDFCore
import RDFKit

@Suite(.tags(.property, .rdfs))
struct RDFSCommentTests {
    /// rdfs:comment rdfs:domain rdfs:Resource, the root, so it is its own
    /// protocol, RDFS.Comment, inheriting its domain; an individual's class
    /// adopts it, and its values are literals (D4, D5, D6).
    @Test func isAProtocolTheIndividualAdopts() {
        let alice = Person()
        alice.comment.insert(Text(value: "A person."))
        alice.comment.insert(Text(value: "A person."))
        #expect(alice.comment.count == 1)
    }

    private final class Person: RDFS.Comment {
        var comment: Values<any RDFS.Literal> = []
    }

    private struct Text: RDFS.Literal, Equatable {
        let value: String
    }
}
