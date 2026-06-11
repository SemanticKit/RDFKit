import Foundation

/// A declaration whose value is text.
public struct TextAssertion<Role>: Content {
    let value: String

    public init(_ value: String) {
        self.value = value
    }
}
