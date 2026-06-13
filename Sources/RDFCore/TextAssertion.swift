import Foundation

/// A declaration whose value is text.
public struct TextAssertion<Role>: Content {
    /// The authored text value.
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}
