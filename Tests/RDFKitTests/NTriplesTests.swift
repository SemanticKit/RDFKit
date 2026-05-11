import Testing
import SemanticKit
@testable import RDFKit

@Test func ntriplesRejectsUnescapedNewlineInLiteral() async throws {
    let ntriples = """
    <https://example.com/s> <https://example.com/p> "line1
    line2" .
    """

    do {
        _ = try Graph(ntriples: ntriples)
        #expect(Bool(false), "Expected parser to reject unescaped newline in literal.")
    } catch {
        #expect(Bool(true))
    }
}

@Test func ntriplesIgnoresVersionDirective() async throws {
    let ntriples = """
    VERSION "1.2"
    <https://example.com/s> <https://example.com/p> "hello" .
    """

    let graph = try Graph(ntriples: ntriples)
    let s = try AnyRDFSubject(IRI("https://example.com/s"))
    let p = try IRI("https://example.com/p")
    let o = try AnyRDFObject(Literal("hello"))

    #expect(graph.contains(Graph.TripleType(subject: s, predicate: p, object: o)))
}

@Test func ntriplesAcceptsUnicodeEscapes() async throws {
    let ntriples = """
    <https://example.com/\\u00E9> <https://example.com/p> "caf\\u00E9" .
    """

    let graph = try Graph(ntriples: ntriples)
    let subject = try AnyRDFSubject(IRI("https://example.com/é"))
    let predicate = try IRI("https://example.com/p")
    let object = try AnyRDFObject(Literal("café"))

    #expect(graph.contains(Graph.TripleType(subject: subject, predicate: predicate, object: object)))
}

@Test func ntriplesParsesSimpleTerms() async throws {
    let ntriples = """
    <https://example.com/s> <https://example.com/p> "hello"@en .
    _:b0 <https://example.com/p> <https://example.com/o> .
    """

    let graph = try Graph(ntriples: ntriples)
    let s = try AnyRDFSubject(IRI("https://example.com/s"))
    let p = try IRI("https://example.com/p")
    let hello = try AnyRDFObject(Literal("hello", languageTag: "en"))
    let o = try AnyRDFObject(IRI("https://example.com/o"))

    #expect(graph.contains(Graph.TripleType(subject: s, predicate: p, object: hello)))
    #expect(graph.contains(Graph.TripleType(subject: try AnyRDFSubject(BlankNode("b0")), predicate: p, object: o)))
}

@Test func ntriplesRejectsInvalidBlankNodeLabels() async throws {
    let ntriples = """
    _:-bad <https://example.com/p> <https://example.com/o> .
    _:bad. <https://example.com/p> <https://example.com/o> .
    """

    do {
        _ = try Graph(ntriples: ntriples)
        #expect(Bool(false), "Expected parser to reject invalid blank node labels.")
    } catch {
        #expect(Bool(true))
    }
}

@Test func ntriplesRejectsInvalidLanguageTags() async throws {
    let ntriples = """
    <https://example.com/s> <https://example.com/p> "hello"@en- .
    """

    do {
        _ = try Graph(ntriples: ntriples)
        #expect(Bool(false), "Expected parser to reject invalid language tag.")
    } catch {
        #expect(Bool(true))
    }
}
