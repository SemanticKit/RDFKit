import IRIKit

/// A prefix label bound to a namespace, which a Turtle document declares
/// with `@prefix` and writes IRIs in its namespace with (RDF 1.2 Turtle
/// §2.4).
///
///     Prefix("foaf", "http://xmlns.com/foaf/0.1/")
public struct Prefix: Hashable, Sendable {
    /// The prefix label.
    public let prefix: String

    /// The namespace IRI the prefix abbreviates.
    public let namespace: IRI

    /// Creates a prefix binding.
    public init(_ prefix: String, _ namespace: IRI) {
        self.prefix = prefix
        self.namespace = namespace
    }
}
