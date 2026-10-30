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
        #expect(left.isIsomorphic(to: try left.roundTripped()))
    }

    @Test("Blank nodes inside triple terms are mapped with the rest")
    func tripleTermIsomorphism() throws {
        let graph = try Fixture.graph("triple-term-blank-nodes.nt")
        #expect(graph.isIsomorphic(to: try Fixture.graph("triple-term-blank-nodes-relabelled.nt")))
        #expect(!graph.isIsomorphic(to: try Fixture.graph("triple-term-blank-nodes-reversed.nt")))
        #expect(graph.isIsomorphic(to: try graph.roundTripped()))
    }

    /// A 200-node chain of blank nodes against the same chain with shuffled
    /// labels and triples: every node looks alike until colours are refined
    /// to the end of the chain.
    @Test("A long blank node chain is isomorphic to itself relabelled, in bounded time", .timeLimit(.minutes(1)))
    func longChain() throws {
        let chain = try Fixture.graph("blank-chain.nt")
        let shuffled = try Fixture.graph("blank-chain-shuffled.nt")
        #expect(chain.count == 200)
        #expect(chain != shuffled)
        let elapsed = ContinuousClock().measure {
            #expect(chain.isIsomorphic(to: shuffled))
            #expect(shuffled.isIsomorphic(to: chain))
        }
        #expect(elapsed < .seconds(10))
    }

    /// One 48-node blank cycle against two 24-node cycles: the same number
    /// of nodes and triples, every node of either with one triple in and one
    /// out, and no bijection.
    @Test("One blank node cycle is not two, decided in bounded time", .timeLimit(.minutes(1)))
    func cycles() throws {
        let one = try Fixture.graph("blank-cycle.nt")
        let two = try Fixture.graph("blank-two-cycles.nt")
        #expect(one.count == two.count)
        let elapsed = ContinuousClock().measure {
            #expect(!one.isIsomorphic(to: two))
            #expect(!two.isIsomorphic(to: one))
            #expect(one.isIsomorphic(to: one))
            #expect(two.isIsomorphic(to: two))
        }
        #expect(elapsed < .seconds(10))
        #expect(two.isIsomorphic(to: try two.roundTripped()))
    }
}
