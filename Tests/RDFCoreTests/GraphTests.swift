import RDFCore
import Testing

/// An RDF graph is a set of triples (RDF 1.2 Concepts §3.7), checked on
/// graphs decoded from N-Triples fixtures.
@Suite("Graph", .tags(.graph))
struct GraphTests {
    @Test("A graph is a set: it holds a triple once, and its order is not part of its value")
    func setSemantics() throws {
        var graph = try Fixture.graph("set.nt")
        let reversed = try Fixture.graph("set-reversed.nt")
        #expect(graph.count == 2)
        #expect(graph == reversed)
        #expect(Array(graph) == Array(reversed).reversed())
        let a = try #require(graph.first)
        let b = try #require(reversed.first)
        #expect(graph.insert(a).inserted == false)
        #expect(graph.count == 2)
        #expect(graph.remove(a) == a)
        #expect(graph == [b])
    }

    @Test("Triples match a pattern whose missing components match anything")
    func matching() throws {
        let graph = try Fixture.graph("matching.nt")
        let first = try #require(graph.first)
        let second = try #require(graph.dropFirst().first)
        let other = try #require(try Fixture.graph("other-subject.nt").first)
        #expect(graph.triples(predicate: second.predicate) == [second])
        #expect(graph.triples(subject: first.subject, object: first.object) == graph)
        #expect(graph.triples(subject: other.subject).isEmpty)
    }

    @Test("Graphs that differ only in blank node identifiers are isomorphic, not equal")
    func isomorphism() throws {
        let left = try Fixture.graph("chain-ab.nt")
        let right = try Fixture.graph("chain-bc.nt")
        #expect(left != right)
        #expect(left.isIsomorphic(to: right))
        #expect(!left.isIsomorphic(to: try Fixture.graph("chain-bc-more.nt")))
        #expect(!left.isIsomorphic(to: try Fixture.graph("chain-ab-swapped.nt")))
    }
}
