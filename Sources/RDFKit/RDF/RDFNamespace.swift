import Foundation

/// The RDF namespace.
public struct RDF: Equatable, Hashable, Sendable, IRIRepresentable, TypeIRIRepresentable, AliasTarget {
    /// The RDF namespace IRI.
    public static var iri: IRI { declaredNamespace.iri }

    /// The RDF namespace.
    public static var declaredNamespace: Namespace { Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#") }

    /// The RDF namespace IRI.
    public var iri: IRI { Self.iri }

    /// Creates an RDF namespace DSL value.
    public init() {}

    /// Returns the RDF namespace.
    public func aliasNamespace() throws -> Namespace { Self.declaredNamespace }
}
