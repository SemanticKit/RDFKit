import Foundation

/// The RDF Schema namespace.
public struct RDFS: Equatable, Hashable, Sendable, IRIRepresentable, TypeIRIRepresentable, AliasTarget {
    /// The RDFS namespace IRI.
    public static var iri: IRI { declaredNamespace.iri }

    /// The RDFS namespace.
    public static var declaredNamespace: Namespace { Namespace("http://www.w3.org/2000/01/rdf-schema#") }

    /// The RDFS namespace IRI.
    public var iri: IRI { Self.iri }

    /// Creates an RDFS namespace DSL value.
    public init() {}

    /// Returns the RDFS namespace.
    public func aliasNamespace() throws -> Namespace { Self.declaredNamespace }
}
