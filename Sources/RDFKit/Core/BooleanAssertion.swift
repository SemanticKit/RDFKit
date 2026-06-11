import Foundation

/// A declaration whose value is boolean.
public struct BooleanAssertion<Role>: Content {
    let value: Bool

    public init(_ value: Bool = true) {
        self.value = value
    }
}
