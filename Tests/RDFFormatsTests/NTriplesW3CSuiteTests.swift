import Foundation
import RDFFormats
import Testing

/// The W3C RDF 1.2 N-Triples suite (`rdf/rdf12/rdf-n-triples/manifest.ttl`),
/// which includes the RDF 1.1 N-Triples suite.
@Suite("W3C RDF 1.2 N-Triples suite", .tags(.w3c, .nTriples, .boundary))
struct NTriplesW3CSuiteTests {
    static let manifest = "rdf/rdf12/rdf-n-triples/manifest.ttl"

    @Test("Every N-Triples manifest entry runs")
    func manifestIsComplete() throws {
        let tests = try W3CManifest.tests(in: Self.manifest)
        #expect(tests.count == 145)
        #expect(Set(tests.map(\.id)).count == tests.count)
    }

    @Test("Positive syntax: the document decodes", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .positiveSyntax })
    func positiveSyntax(_ test: W3CTestCase) throws {
        _ = try NTriplesDecoder().decode(try test.readAction())
    }

    @Test("Negative syntax: the document is rejected", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .negativeSyntax })
    func negativeSyntax(_ test: W3CTestCase) throws {
        let document = try test.readAction()
        #expect(throws: SyntaxError.self) { try NTriplesDecoder().decode(document) }
    }

    @Test("Canonicalization: the encoder writes the canonical form", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .canonicalization })
    func canonicalization(_ test: W3CTestCase) throws {
        let graph = try NTriplesDecoder().decode(try test.readAction())
        let encoded = NTriplesEncoder().encode(graph)
        let expected = try test.readResult()
        #expect(Array(encoded.utf8) == Array(expected.utf8), "\(encoded)")
    }
}
