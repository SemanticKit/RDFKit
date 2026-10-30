import IRIKit
import RDFCore
import Testing

@Suite("Graph", .tags(.graph))
struct GraphTests {
    let s: SubjectTerm = .iri("http://example/s")
    let p: IRI = "http://example/p"
    let q: IRI = "http://example/q"

    @Test("A graph is a set: it holds a triple once, and its order is not part of its value")
    func setSemantics() throws {
        let a = Graph.Element(subject: s, predicate: p, object: .literal(Literal("a")))
        let b = Graph.Element(subject: s, predicate: p, object: .literal(Literal("b")))
        var graph: Graph = [a, b]
        #expect(graph.insert(a).inserted == false)
        #expect(graph.count == 2)
        #expect(graph == [b, a])
        #expect(Array(graph) == [a, b])
        #expect(graph.symmetricDifference([b, Graph.Element(subject: s, predicate: q, object: .literal(Literal("c")))]).count == 2)
        #expect(graph.remove(a) == a)
        #expect(graph == [b])
    }

    @Test("Triples match a pattern whose missing components match anything")
    func matching() {
        let o: ObjectTerm = .iri("http://example/o")
        let first = Graph.Element(subject: s, predicate: p, object: o)
        let second = Graph.Element(subject: s, predicate: q, object: o)
        let graph: Graph = [first, second]
        #expect(graph.triples(predicate: q) == [second])
        #expect(graph.triples(subject: s, object: o) == graph)
        #expect(graph.triples(subject: .iri("http://example/other")).isEmpty)
    }

    @Test("Graphs that differ only in blank node identifiers are isomorphic, not equal")
    func isomorphism() throws {
        func chain(_ first: String, _ second: String) throws -> Graph {
            let x = SubjectTerm.blankNode(try BlankNode(first))
            let y = SubjectTerm.blankNode(try BlankNode(second))
            return [
                Graph.Element(subject: s, predicate: p, object: x.object),
                Graph.Element(subject: x, predicate: p, object: y.object),
                Graph.Element(subject: y, predicate: q, object: .literal(Literal("end"))),
            ]
        }
        let left = try chain("a", "b")
        let right = try chain("b", "c")
        #expect(left != right)
        #expect(left.isIsomorphic(to: right))

        var other = right
        other.insert(Graph.Element(subject: .blankNode(try BlankNode("c")), predicate: q, object: .literal(Literal("more"))))
        #expect(!left.isIsomorphic(to: other))

        let swapped = try chain("a", "b").map { triple in
            Graph.Element(subject: triple.subject, predicate: triple.predicate == p ? q : p, object: triple.object)
        }
        #expect(!left.isIsomorphic(to: Graph(swapped)))
    }
}
