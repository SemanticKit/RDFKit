import Foundation

/// Declares OWL deprecation metadata as authored content.
public struct OWLDeprecated: Content {
    /// Whether the declaration is deprecated.
    let value: Bool

    /// Creates a deprecation declaration.
    public init(_ value: Bool = true) {
        self.value = value
    }
}
