import Foundation

/// Declares an RDFS comment as authored content.
public struct Comment: Content {
    /// The comment text.
    let value: String

    /// Creates a comment declaration.
    public init(_ value: String) {
        self.value = value
    }
}
