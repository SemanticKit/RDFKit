import IRIKit
import RDFCore
import Testing

@Suite("TripleTerm", .tags(.term))
struct TripleTermTests {
    let s: SubjectTerm = .iri("http://example/s")
    let p: IRI = "http://example/p"
    let q: IRI = "http://example/q"

    @Test("A triple is a triple term in object position")
    func objectPosition() throws {
        let inner = Graph.Element(subject: s, predicate: p, object: .literal(try Literal("v", languageTag: "en", baseDirection: .ltr)))
        let reifier: SubjectTerm = .blankNode(try BlankNode("r"))
        let graph: Graph = [Graph.Element(subject: reifier, predicate: q, object: .tripleTerm(inner))]
        guard case .tripleTerm(let term)? = graph.first?.object else {
            Issue.record("expected a triple term")
            return
        }
        #expect(term == inner)
        #expect(graph.description == #"_:r <http://example/q> <<( <http://example/s> <http://example/p> "v"@en--ltr )>> ."#)
    }

    @Test("Triple terms are equal when their components are equal")
    func equality() throws {
        let one = ObjectTerm.tripleTerm(Graph.Element(subject: s, predicate: p, object: .literal(Literal("v"))))
        let same = ObjectTerm.tripleTerm(Graph.Element(subject: s, predicate: p, object: .literal(Literal("v"))))
        let other = ObjectTerm.tripleTerm(Graph.Element(subject: s, predicate: q, object: .literal(Literal("v"))))
        #expect(one == same)
        #expect(one != other)
    }
}
