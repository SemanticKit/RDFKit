import Foundation
import Testing
import RDFCore
import RDFFormats

@Suite(.tags(.rdfs))
struct TurtleRoundTripTests {
    /// The published rdfs.ttl, read with the grammar RDF 1.2 Turtle
    /// publishes, survives a round trip through N-Triples and Turtle.
    @Test func rdfsRoundTrips() throws {
        let url = try #require(Bundle.module.url(forResource: "rdfs", withExtension: "ttl", subdirectory: "Fixtures"))
        let graph = try TurtleDecoder().decode(String(contentsOf: url, encoding: .utf8))
        #expect(!graph.isEmpty)

        let nTriples = try NTriplesDecoder().decode(NTriplesEncoder().encode(graph))
        #expect(nTriples.isIsomorphic(to: graph))

        let turtle = try TurtleDecoder().decode(TurtleEncoder().encode(graph))
        #expect(turtle.isIsomorphic(to: graph))
    }
}
