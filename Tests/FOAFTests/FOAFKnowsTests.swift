import Testing
import RDFCore
import RDFKit
import FOAF

@Suite(.tags(.property, .foaf))
struct FOAFKnowsTests {
    /// foaf:knows rdfs:domain foaf:Person and rdfs:range foaf:Person, so it
    /// is a requirement of FOAF.Person whose values are people, compared by
    /// identity, cycles included (D3, D4, D5).
    @Test func isARequirementOfPerson() {
        let alice = Person(), bob = Person()
        alice.knows.insert(bob)
        bob.knows.insert(alice)
        #expect(alice.knows.contains { $0 === bob })
        #expect(bob.knows.contains { $0 === alice })
    }

    private final class Person: FOAF.Person {
        var knows: Values<any FOAF.Person> = []
    }
}
