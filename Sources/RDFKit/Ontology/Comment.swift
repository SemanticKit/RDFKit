import Foundation

/// Declares an RDFS comment inside ontology declaration content.
public struct Comment: Content {
    /// The comment text.
    let value: String

    /// Creates a comment declaration.
    public init(_ value: String) {
        self.value = value
    }
}
