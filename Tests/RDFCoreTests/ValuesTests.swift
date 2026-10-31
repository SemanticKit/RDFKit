import Testing
@testable import RDFCore

@Suite(.tags(.property))
struct ValuesTests {
    private final class Person {}
    private protocol Agent {}
    private final class Member: Agent {}

    /// Two individuals are the same value only when they are the same object (D3).
    @Test func individualsAreComparedByIdentity() {
        let alice = Person(), bob = Person()
        var knows: Values<Person> = [alice]
        #expect(knows.insert(alice).inserted == false)
        #expect(knows.insert(bob).inserted)
        #expect(knows.count == 2)
        #expect(knows.contains { $0 === bob })
    }

    /// Two literals are the same value when their Swift values are equal (D6).
    @Test func literalsAreComparedByEquality() {
        var names: Values<String> = ["Alice", "Alice", "Al"]
        #expect(names.count == 2)
        #expect(names.remove("Al") == "Al")
        #expect(names == ["Alice"])
    }

    /// A range that is a protocol, which is not Hashable, still has set semantics.
    @Test func existentialElementsHaveSetSemantics() {
        let member = Member()
        let agents: Values<any Agent> = [member, member, Member()]
        #expect(agents.count == 2)
        #expect(agents.contains(member))
    }

    /// Set algebra on values.
    @Test func setAlgebra() {
        let first: Values<Int> = [1, 2, 3]
        let second: Values<Int> = [2, 3, 4]
        #expect(first.union(second) == [1, 2, 3, 4])
        #expect(first.intersection(second) == [2, 3])
        #expect(first.symmetricDifference(second) == [1, 4])
    }
}
