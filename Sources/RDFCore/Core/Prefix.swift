import Foundation
import IRIKit

/// A prefix alias bound to a namespace, for serialization.
///
///     Prefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
public struct Prefix: Entity {
    /// The alias prefix.
    public let prefix: String

    /// The namespace IRI the prefix abbreviates.
    public let namespace: IRI

    /// Creates a prefix alias.
    public init(_ prefix: String, _ namespace: IRI) {
        self.prefix = prefix
        self.namespace = namespace
    }
}
