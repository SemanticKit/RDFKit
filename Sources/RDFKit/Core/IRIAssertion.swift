import Foundation
import IRIKit

/// A declaration whose value is an authored IRI reference.
public struct IRIAssertion<Role>: Content {
    let value: String

    public init(_ value: IRI) {
        self.value = value.description
    }

    public init(_ value: String) {
        self.value = value
    }
}
