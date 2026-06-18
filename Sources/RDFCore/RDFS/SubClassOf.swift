import Foundation

// MARK: - Protocol

/// Declares a superclass relationship.
///
/// From RDFS: Used to state that all instances of one class are instances
/// of another. Domain: rdfs:Class, range: rdfs:Class. Transitive.
public protocol SubClassOfAnnotation: TermContent {
    /// The superclass term.
    var term: any Node { get }
}

// MARK: - Concrete Type

/// Declares a superclass relationship.
public struct SubClassOfAnnotationValue: SubClassOfAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "SubClassedTerm"
    public let contributionTypeName: String = "SubClassOfAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

// MARK: - DSL

/// Declares a superclass relationship.
///
///     SubClassOf(RDFS.Resource)
public func SubClassOf(_ term: any Node) -> SubClassOfAnnotationValue {
    SubClassOfAnnotationValue(term)
}
