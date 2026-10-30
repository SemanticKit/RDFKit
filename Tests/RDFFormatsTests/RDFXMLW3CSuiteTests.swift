import Foundation
import RDFFormats
import Testing

/// The W3C RDF 1.2 XML Syntax suite (`rdf/rdf12/rdf-xml/manifest.ttl`), which
/// includes the RDF 1.1 RDF/XML suite.
@Suite("W3C RDF 1.2 XML suite", .tags(.w3c, .rdfXML, .boundary))
struct RDFXMLW3CSuiteTests {
    static let manifest = "rdf/rdf12/rdf-xml/manifest.ttl"

    @Test("Every RDF/XML manifest entry runs")
    func manifestIsComplete() throws {
        let tests = try W3CManifest.tests(in: Self.manifest)
        #expect(tests.count == 197)
        #expect(Set(tests.map(\.id)).count == tests.count)
        #expect(tests.allSatisfy { $0.kind == .evaluation || $0.kind == .negativeSyntax })
    }

    @Test("Negative syntax: the document is rejected", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .negativeSyntax })
    func negativeSyntax(_ test: W3CTestCase) throws {
        let document = try test.readAction()
        #expect(throws: SyntaxError.self) { try RDFXMLDecoder(base: test.action).decode(document) }
    }

    @Test("Evaluation: the graph is isomorphic to the expected N-Triples", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .evaluation })
    func evaluation(_ test: W3CTestCase) throws {
        let decoded = try RDFXMLDecoder(base: test.action).decode(try test.readAction())
        let expected = try NTriplesDecoder().decode(try test.readResult())
        #expect(decoded.isIsomorphic(to: expected), "\(NTriplesEncoder().encode(decoded))")
    }

    @Test("Round trip: the graph encodes to RDF/XML that decodes to an isomorphic graph", arguments: try W3CManifest.tests(in: manifest).filter { $0.kind == .evaluation })
    func roundTrip(_ test: W3CTestCase) throws {
        let graph = try RDFXMLDecoder(base: test.action).decode(try test.readAction())
        let document = try RDFXMLEncoder().encode(graph)
        let decoded = try RDFXMLDecoder().decode(document)
        #expect(decoded.isIsomorphic(to: graph), "\(document)")
    }
}
