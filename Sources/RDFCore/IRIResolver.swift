import Foundation
import IRIKit

/// Resolves term names to full IRIs using a namespace.
///
/// An `IRIResolver` captures the namespace context of an ontology and
/// provides IRI resolution for any term name within that namespace.
///
///     let resolver = OWL().iriResolver
///     let classIRI = resolver.resolve("Class")
///     // IRI("http://www.w3.org/2002/07/owl#Class")
public struct IRIResolver: Sendable {

    /// The namespace used for IRI resolution.
    public let namespace: Namespace

    /// Creates a resolver from a namespace.
    public init(_ namespace: Namespace) {
        self.namespace = namespace
    }

    /// Resolves a term name to its full IRI.
    ///
    /// The IRI is formed by appending the term name to the namespace IRI.
    public func resolve(_ name: String) -> IRI {
        let iriString = namespace.rawValue + name
        return try! IRI(validating: iriString)
    }

    /// Resolves a term name to a string IRI.
    public func resolveString(_ name: String) -> String {
        namespace.rawValue + name
    }
}
