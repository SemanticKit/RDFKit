import Foundation

// MARK: - Protocol

/// Assigns an RDF type to a term.
///
/// From RDF: Used to state that a resource is an instance of a class.
public protocol TypeAnnotation: TermContent {
    /// The type term being assigned.
    var term: any Node { get }
}

// MARK: - Concrete Type

/// Assigns an RDF type to a term.
public struct TypeAnnotationValue: TypeAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "TypedTerm"
    public let contributionTypeName: String = "TypeAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

// MARK: - DSL

/// Assigns an RDF type to a term.
///
///     Type(RDFS.Class)
///     Type(RDF.Property)
public func Type(_ term: any Node) -> TypeAnnotationValue {
    TypeAnnotationValue(term)
}
