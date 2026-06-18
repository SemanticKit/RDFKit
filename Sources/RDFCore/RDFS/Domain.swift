import Foundation

// MARK: - Protocol

/// Declares the domain of a property.
///
/// From RDFS: Used to state that any resource that has a given property
/// is an instance of one or more classes.
public protocol DomainAnnotation: TermContent {
    /// The domain term.
    var term: any Node { get }
}

// MARK: - Concrete Type

/// Declares the domain of a property.
public struct DomainAnnotationValue: DomainAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "DomainTerm"
    public let contributionTypeName: String = "DomainAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

// MARK: - DSL

/// Declares the domain of a property.
///
///     Domain(RDFS.Resource)
public func Domain(_ term: any Node) -> DomainAnnotationValue {
    DomainAnnotationValue(term)
}
