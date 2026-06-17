import Testing
@testable import RDFCore

@Suite(.tags(.property, .characteristic))
struct ReflexivePropertyTests {

    @Test("Reflexive property includes self")
    func reflexive() {
        let person = Person(name: "Alice")
        let knows = person.knows
        #expect(knows.contains(person))
    }
}
