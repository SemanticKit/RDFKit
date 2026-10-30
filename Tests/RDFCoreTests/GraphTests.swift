import RDFCore
import Testing

@Suite("Graph", .tags(.graph))
struct GraphTests {
    @Test("A graph is a set: it holds a triple once, and its order is not part of its value")
    func setSemantics() throws {
        let graph = try Graph(fixture: "graph-set.ttl")
        #expect(graph.count == 3)
        let (a, b, c) = (graph[0], graph[1], graph[2])
        var copy = graph
        #expect(copy.insert(a).inserted == false)
        #expect(copy == Graph([c, b, a]))
        #expect(Array(copy) == [a, b, c])
        #expect(copy.symmetricDifference([b]) == [a, c])
        #expect(copy.remove(a) == a)
        #expect(copy == [b, c])
    }

    @Test("Triples match a pattern whose missing components match anything")
    func matching() throws {
        let graph = try Graph(fixture: "graph-set.ttl")
        let other = graph[2]
        #expect(graph.triples(predicate: other.predicate) == [other])
        #expect(graph.triples(subject: other.subject, object: other.object) == [other])
        #expect(graph.triples(subject: other.subject) == graph)
        // The predicate's IRI is the subject of no triple.
        #expect(graph.triples(subject: .iri(other.predicate)).isEmpty)
    }

    @Test("Graphs that differ only in blank node identifiers are isomorphic, not equal")
    func isomorphism() throws {
        let chain = try Graph(fixture: "chain.ttl")
        let relabelled = try Graph(fixture: "chain-relabelled.ttl")
        #expect(chain != relabelled)
        #expect(chain.isIsomorphic(to: relabelled))
        #expect(!chain.isIsomorphic(to: try Graph(fixture: "chain-longer.ttl")))
        #expect(!chain.isIsomorphic(to: try Graph(fixture: "chain-swapped.ttl")))
        #expect(chain.isIsomorphic(to: try chain.roundTripped()))
    }

    @Test("Blank nodes inside triple terms are mapped with the rest")
    func tripleTermIsomorphism() throws {
        let graph = try Graph(fixture: "triple-term-blank-nodes.ttl")
        #expect(graph.isIsomorphic(to: try Graph(fixture: "triple-term-blank-nodes-relabelled.ttl")))
        #expect(!graph.isIsomorphic(to: try Graph(fixture: "triple-term-blank-nodes-reversed.ttl")))
    }

    /// A 200-node chain of blank nodes against the same chain with shuffled
    /// labels and triples: every node looks alike until colours are refined
    /// to the end of the chain.
    @Test("A long blank node chain is isomorphic to itself relabelled, in bounded time", .timeLimit(.minutes(1)))
    func longChain() throws {
        let chain = try Graph(fixture: "blank-chain.nt")
        let shuffled = try Graph(fixture: "blank-chain-shuffled.nt")
        #expect(chain.count == 200)
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
        let one = try Graph(fixture: "blank-cycle.nt")
        let two = try Graph(fixture: "blank-two-cycles.nt")
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
