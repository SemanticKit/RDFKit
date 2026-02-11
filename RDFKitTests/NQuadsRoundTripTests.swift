import Testing
import SemanticKit
@testable import RDFKit

@Test func tripleTermRoundTripInNQuads() async throws {
    let s = try AnyRDFSubject(IRI("https://example.com/s"))
    let p = try IRI("https://example.com/p")
    let term = TripleTerm(subject: s, predicate: p, object: AnyRDFObject(try Literal("c")))
    let g = try IRI("https://example.com/g")

    var graph = try Graph(name: g)
    try graph.insert(Graph.TripleType(subject: s, predicate: p, object: AnyRDFObject(term)))
    let dataset = Dataset(defaultGraph: Graph(), namedGraphs: [g: graph])

    let roundTrip = try Dataset(nquads: dataset.nquadsString())
    let roundGraph = roundTrip.graph(named: g)
    #expect(roundGraph?.contains(Graph.TripleType(subject: s, predicate: p, object: AnyRDFObject(term))) == true)
}
