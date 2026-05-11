import Testing
import SemanticKit
@testable import RDFKit

@Test func nquadsParsesDatasetWithGraphsAndTripleTerms() async throws {
    let nquads = """
    VERSION "1.2"
    <https://example.com/s> <https://example.com/p> "hello"@en--ltr .
    <https://example.com/s> <https://example.com/p> <<( <https://example.com/a> <https://example.com/b> "c" )>> <https://example.com/graph> .
    """

    let dataset = try Dataset(nquads: nquads)

    let s = try IRI("https://example.com/s")
    let p = try IRI("https://example.com/p")
    let a = try IRI("https://example.com/a")
    let b = try IRI("https://example.com/b")
    let graphIri = try IRI("https://example.com/graph")

    let subject = try AnyRDFSubject(s)
    let literal = try Literal("hello", languageTag: "en", textDirection: .ltr)

    #expect(dataset.defaultGraph.contains(Graph.TripleType(
        subject: subject,
        predicate: p,
        object: AnyRDFObject(literal)
    )))

    let tripleTerm = TripleTerm(
        subject: try AnyRDFSubject(a),
        predicate: b,
        object: AnyRDFObject(try Literal("c"))
    )

    let namedGraph = dataset.graph(named: graphIri)
    #expect(namedGraph != nil)
    #expect(namedGraph?.contains(Graph.TripleType(
        subject: subject,
        predicate: p,
        object: AnyRDFObject(tripleTerm)
    )) == true)
}

@Test func nquadsSerializesDataset() async throws {
    let s = try IRI("https://example.com/s")
    let p = try IRI("https://example.com/p")
    let g = try IRI("https://example.com/graph")

    let subject = try AnyRDFSubject(s)
    let literal = try Literal("hello", languageTag: "en", textDirection: .rtl)

    var defaultGraph = Graph()
    try defaultGraph.insert(Graph.TripleType(
        subject: subject,
        predicate: p,
        object: AnyRDFObject(literal)
    ))

    var namedGraph = try Graph(name: g)
    let tripleTerm = TripleTerm(
        subject: subject,
        predicate: p,
        object: AnyRDFObject(try Literal("c"))
    )
    try namedGraph.insert(Graph.TripleType(
        subject: subject,
        predicate: p,
        object: AnyRDFObject(tripleTerm)
    ))

    let dataset = Dataset(defaultGraph: defaultGraph, namedGraphs: [g: namedGraph])
    let output = dataset.nquadsString()

    #expect(output.contains("\"hello\"@en--rtl"))
    #expect(output.contains("<https://example.com/graph>"))
    #expect(output.contains("<<( <https://example.com/s> <https://example.com/p> \"c\" )>>"))
}

@Test func nquadsRejectsBlankNodeGraphName() async throws {
    let nquads = """
    <https://example.com/s> <https://example.com/p> "hello" _:g0 .
    """

    do {
        _ = try Dataset(nquads: nquads)
        #expect(Bool(false), "Expected parser to reject blank node graph name.")
    } catch {
        #expect(Bool(true))
    }
}

@Test func nquadsAcceptsUnicodeEscapes() async throws {
    let nquads = """
    <https://example.com/\\u00E9> <https://example.com/p> "caf\\u00E9" <https://example.com/g> .
    """

    let dataset = try Dataset(nquads: nquads)
    let s = try AnyRDFSubject(IRI("https://example.com/é"))
    let p = try IRI("https://example.com/p")
    let g = try IRI("https://example.com/g")
    let o = try AnyRDFObject(Literal("café"))

    let graph = dataset.graph(named: g)
    #expect(graph?.contains(Graph.TripleType(subject: s, predicate: p, object: o)) == true)
}
