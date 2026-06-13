import Foundation

/// A declaration whose value is boolean.
public struct BooleanAssertion<Role>: Content {
    /// The authored boolean value.
    public let value: Bool

    public init(_ value: Bool = true) {
        self.value = value
    }
}
