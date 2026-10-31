import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFNameTests {
    /// foaf:name rdfs:domain owl:Thing, the root, so it is its own protocol,
    /// FOAF.Name, which an individual's class adopts; its values are
    /// literals (D4, D5, D6).
    @Test func isAProtocolTheIndividualAdopts() {
        let alice = Person()
        alice.name.insert(Text(value: "Alice"))
        #expect(alice.name.count == 1)
    }

    private final class Person: FOAF.Person, FOAF.Name {
        var knows: Values<any FOAF.Person> = []
        var name: Values<any RDFS.Literal> = []
    }

    private struct Text: RDFS.Literal, Equatable {
        let value: String
    }
}
