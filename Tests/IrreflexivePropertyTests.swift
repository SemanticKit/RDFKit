import Testing
@testable import RDFCore

@Suite(.tags(.property, .characteristic))
struct IrreflexivePropertyTests {

    @Test("Irreflexive property excludes self")
    func irreflexive() {
        let person = Person(name: "Alice")
        let parentOf = person.parentOf
        #expect(!parentOf.contains(person))
    }
}
