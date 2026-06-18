import Foundation

// MARK: - Protocol

/// Declares a superproperty relationship.
///
/// From RDFS: Used to state that all resources related by one property
/// are also related by another. Domain: rdf:Property, range: rdf:Property. Transitive.
public protocol SubPropertyOfAnnotation: TermContent {
    /// The superproperty term.
    var term: any Node { get }
}

// MARK: - Concrete Type

/// Declares a superproperty relationship.
public struct SubPropertyOfAnnotationValue: SubPropertyOfAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "SubPropertyOfTerm"
    public let contributionTypeName: String = "SubPropertyOfAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

// MARK: - DSL

/// Declares a superproperty relationship.
///
///     SubPropertyOf(RDFS.SeeAlso)
public func SubPropertyOf(_ term: any Node) -> SubPropertyOfAnnotationValue {
    SubPropertyOfAnnotationValue(term)
}
