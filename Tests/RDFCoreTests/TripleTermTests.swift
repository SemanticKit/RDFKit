import RDFCore
import Testing

@Suite("TripleTerm", .tags(.term))
struct TripleTermTests {
    @Test("A triple is a triple term in object position, equal when its components are")
    func objectPosition() throws {
        // The first two triples state the same triple term; the third's
        // has another predicate.
        let graph = try Graph(fixture: "triple-term.ttl")
        #expect(graph.count == 2)
        guard case .tripleTerm(let first) = graph[0].object, case .tripleTerm(let second) = graph[1].object else {
            Issue.record("expected triple terms")
            return
        }
        #expect(first.subject == second.subject)
        #expect(first.object == second.object)
        #expect(first != second)
        #expect(first.object.description.hasSuffix("@en--ltr"))
        #expect(graph.isIsomorphic(to: try graph.roundTripped()))
    }
}
