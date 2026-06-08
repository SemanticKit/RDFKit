import Foundation

/// The OWL namespace.
public struct OWL: Equatable, Hashable, Sendable, IRIRepresentable, TypeIRIRepresentable, AliasTarget {
    /// The OWL namespace IRI.
    public static var iri: IRI { declaredNamespace.iri }

    /// The OWL namespace.
    public static var declaredNamespace: Namespace { Namespace("http://www.w3.org/2002/07/owl#") }

    /// The OWL namespace IRI.
    public var iri: IRI { Self.iri }

    /// Creates an OWL namespace DSL value.
    public init() {}

    /// Returns the OWL namespace.
    public func aliasNamespace() throws -> Namespace { Self.declaredNamespace }
}
