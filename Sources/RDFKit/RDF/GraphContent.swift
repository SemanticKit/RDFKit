import Foundation

/// RDF content that can materialize itself into a graph.
public protocol GraphContent: Sendable {
    /// Writes this RDF content into a graph.
    func write(to graph: inout Graph) throws
}

extension GraphContent {
    /// Returns this content as a standalone graph.
    public func graph() throws -> Graph {
        var graph = Graph()
        try write(to: &graph)
        return graph
    }
}
