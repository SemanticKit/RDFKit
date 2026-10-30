import Testing
import Dispatch
import FOAF
import RDFCore
import RDFKit

@Suite("An individual's values under concurrent changes", .tags(.generated, .property))
struct IndividualStorageTests {
    static let changes = 2000

    @Test("Concurrent appends to a translated individual's property keep every value")
    func translatedIndividualKeepsConcurrentAppends() {
        let person = FOAF.PersonIndividual()
        DispatchQueue.concurrentPerform(iterations: Self.changes) { index in
            person.name.append(Literal("n\(index)"))
        }
        #expect(person.name.count == Self.changes)
        #expect(Set(person.name.map(\.lexicalForm)).count == Self.changes)
    }

    @Test("Concurrent appends to a DSL individual's property keep every value")
    func dslIndividualKeepsConcurrentAppends() {
        let carol = Club.MemberIndividual()
        let people = (0..<Self.changes).map { _ in FOAF.PersonIndividual() }
        DispatchQueue.concurrentPerform(iterations: Self.changes) { index in
            carol.sponsor.append(people[index])
        }
        #expect(carol.sponsor.count == Self.changes)
        #expect(people.allSatisfy { person in carol.sponsor.contains { $0 === person } })
    }

    @Test("A change in place can read the individual's other properties")
    func changeInPlaceReadsOtherProperties() {
        let carol = Club.MemberIndividual()
        carol.name = ["Carol"]
        carol.firstName.append(contentsOf: carol.name)
        carol.knows.removeAll { _ in carol.name.isEmpty }
        #expect(carol.firstName == ["Carol"])
    }
}
