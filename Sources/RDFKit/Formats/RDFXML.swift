import Foundation

/// RDF/XML RDF graph format.
public struct RDFXML: GraphDecodingFormat, GraphEncodingFormat {
    private let baseIRI: IRI?

    /// Creates an RDF/XML format.
    public init(baseIRI: IRI? = nil) {
        self.baseIRI = baseIRI
    }

    /// Decodes RDF/XML source into a graph.
    public func decodeGraph(_ source: String) throws -> Graph {
        var decoder = RDFXMLDecoder(text: source, baseIRI: baseIRI)
        return try decoder.decodeGraph()
    }

    /// Encodes a graph as RDF/XML source.
    public func encodeGraph(_ graph: Graph) throws -> String {
        let encoder = RDFXMLEncoder(baseIRI: baseIRI)
        return encoder.encode(graph: graph)
    }
}
