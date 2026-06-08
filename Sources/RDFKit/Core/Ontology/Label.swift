import Foundation

/// Declares an RDFS label as authored content.
public struct Label: Content {
    /// The label text.
    let value: String

    /// Creates a label declaration.
    public init(_ value: String) {
        self.value = value
    }
}
