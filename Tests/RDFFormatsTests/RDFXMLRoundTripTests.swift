import Foundation
import Testing
import RDFCore
import RDFFormats

@Suite(.tags(.foaf))
struct RDFXMLRoundTripTests {
    /// FOAF's published index.rdf, read as RDF 1.2 XML Syntax, survives a
    /// round trip through RDF/XML and N-Triples.
    @Test func foafRoundTrips() throws {
        let url = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "../ParallelTests/Fixtures/FOAF/index.rdf")
        let graph = try RDFXMLDecoder().decode(String(contentsOf: url, encoding: .utf8))
        #expect(!graph.isEmpty)

        let rdfXML = try RDFXMLDecoder().decode(RDFXMLEncoder().encode(graph))
        #expect(rdfXML.isIsomorphic(to: graph))

        let nTriples = try NTriplesDecoder().decode(NTriplesEncoder().encode(graph))
        #expect(nTriples.isIsomorphic(to: graph))
    }
}
