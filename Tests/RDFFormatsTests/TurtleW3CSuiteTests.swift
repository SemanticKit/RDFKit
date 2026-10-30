import Foundation
import RDFFormats
import Testing

/// The W3C RDF 1.2 Turtle suite (`rdf/rdf12/rdf-turtle/manifest.ttl`), which
/// includes the RDF 1.1 Turtle suite.
@Suite("W3C RDF 1.2 Turtle suite", .tags(.w3c, .turtle, .boundary))
struct TurtleW3CSuiteTests {
    static let manifest = "rdf/rdf12/rdf-turtle/manifest.ttl"

    @Test("Every Turtle manifest entry runs")
    func manifestIsComplete() throws {
        let tests = try W3CManifest.tests(in: Self.manifest)
        #expect(tests.count == 419)
        #expect(Set(tests.map(\.id)).count == tests.count)
    }

    @Test("Positive syntax: the document decodes", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .positiveSyntax })
    func positiveSyntax(_ test: W3CTestCase) throws {
        _ = try TurtleDecoder(base: test.action).decode(try test.readAction())
    }

    @Test("Negative syntax: the document is rejected", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .negativeSyntax })
    func negativeSyntax(_ test: W3CTestCase) throws {
        let document = try test.readAction()
        #expect(throws: SyntaxError.self) { try TurtleDecoder(base: test.action).decode(document) }
    }

    @Test("Evaluation: the graph is isomorphic to the expected N-Triples", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .evaluation })
    func evaluation(_ test: W3CTestCase) throws {
        let decoded = try TurtleDecoder(base: test.action).decode(try test.readAction())
        let expected = try NTriplesDecoder().decode(try test.readResult())
        #expect(decoded.isIsomorphic(to: expected), "\(NTriplesEncoder().encode(decoded))")
    }
}
