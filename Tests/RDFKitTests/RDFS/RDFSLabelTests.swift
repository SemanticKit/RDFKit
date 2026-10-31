import Testing
import RDFCore
import RDFKit

@Suite(.tags(.property, .rdfs))
struct RDFSLabelTests {
    /// rdfs:label rdfs:domain rdfs:Resource, the root, so it is its own
    /// protocol, RDFS.Label, inheriting its domain; an individual's class
    /// adopts it, and its values are literals (D4, D5, D6).
    @Test func isAProtocolTheIndividualAdopts() {
        let alice = Person()
        alice.label.insert(Text(value: "Alice"))
        alice.label.insert(Text(value: "Alice"))
        #expect(alice.label.count == 1)
    }

    private final class Person: RDFS.Label {
        var label: Values<any RDFS.Literal> = []
    }

    private struct Text: RDFS.Literal, Equatable {
        let value: String
    }
}
