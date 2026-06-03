import Foundation

/// N-Triples RDF graph format.
public struct NTriples: GraphDecodingFormat, GraphEncodingFormat {
    /// Creates an N-Triples format.
    public init() {}

    /// Decodes N-Triples source into a graph.
    public func decodeGraph(_ source: String) throws -> Graph {
        var decoder = NTriplesDecoder(text: source)
        return try decoder.decodeGraph()
    }

    /// Encodes a graph as N-Triples source.
    public func encodeGraph(_ graph: Graph) throws -> String {
        let encoder = NTriplesEncoder()
        return encoder.encode(graph: graph)
    }
}
