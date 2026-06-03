import Foundation

/// Turtle RDF graph format.
public struct Turtle<Aliases: AliasContent>: GraphDecodingFormat, GraphEncodingFormat {
    private let baseIRI: IRI?
    private let aliases: Aliases

    /// Creates a Turtle format with protocol-based alias content.
    public init(baseIRI: IRI? = nil, @AliasBuilder aliases: () -> Aliases) {
        self.baseIRI = baseIRI
        self.aliases = aliases()
    }

    /// Decodes Turtle source into a graph.
    public func decodeGraph(_ source: String) throws -> Graph {
        var decoder = TurtleDecoder(text: source, baseIRI: baseIRI)
        return try decoder.decodeGraph()
    }

    /// Encodes a graph as Turtle source.
    public func encodeGraph(_ graph: Graph) throws -> String {
        let encoder = TurtleEncoder(prefixes: try aliases.iriPrefixMap(), baseIRI: baseIRI)
        return encoder.encode(graph: graph)
    }
}

extension Turtle where Aliases == EmptyAliasContent {
    /// Creates a Turtle format without aliases.
    public init(baseIRI: IRI? = nil) {
        self.baseIRI = baseIRI
        self.aliases = EmptyAliasContent()
    }
}
