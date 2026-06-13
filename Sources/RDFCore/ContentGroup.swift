import Foundation

/// A group of authored RDF content values.
public struct ContentGroup: Node {
    /// The grouped authored content values.
    public let elements: [any Node]

    /// Creates a content group.
    public init(_ elements: [any Node]) {
        self.elements = elements
    }
}
