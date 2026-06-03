import Foundation

/// OWL 2 Functional-Style Syntax graph import format.
public struct OWLFunctionalSyntax: GraphDecodingFormat {
    /// Creates an OWL Functional-Style Syntax format.
    public init() {}

    /// Decodes OWL Functional-Style Syntax source into a graph.
    public func decodeGraph(_ source: String) throws -> Graph {
        var decoder = OWLFunctionalSyntaxDecoder(text: source)
        return try decoder.decodeGraph()
    }
}
