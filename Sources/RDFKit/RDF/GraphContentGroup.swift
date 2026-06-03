import Foundation

/// A group of RDF graph content values that materialize in declaration order.
public struct GraphContentGroup: GraphContent {
    /// The grouped graph content values.
    public let elements: [any GraphContent]

    /// Creates a graph content group.
    public init(_ elements: [any GraphContent]) {
        self.elements = elements
    }

    /// Writes each grouped content value into the graph.
    public func write(to graph: inout Graph) throws {
        for element in elements {
            try element.write(to: &graph)
        }
    }
}
