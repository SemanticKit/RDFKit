import Foundation

/// A prefix alias bound to a namespace.
public struct Alias: Content {
    /// The alias prefix.
    let prefix: String

    /// The target namespace.
    let namespace: Namespace

    /// Creates a prefix alias.
    public init(_ prefix: String, _ namespace: Namespace) {
        self.prefix = prefix
        self.namespace = namespace
    }
}
