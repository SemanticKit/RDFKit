import Foundation

/// A group of authored RDF content values.
public struct ContentGroup: Content {
    /// The grouped authored content values.
    public let elements: [any Content]

    /// Creates a content group.
    public init(_ elements: [any Content]) {
        self.elements = elements
    }
}
