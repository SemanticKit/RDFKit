import Foundation

// MARK: - Protocol

/// Declares the range of a property.
///
/// From RDFS: Used to state that the values of a property are instances
/// of one or more classes.
public protocol RangeAnnotation: TermContent {
    /// The range term.
    var term: any Node { get }
}

// MARK: - Concrete Type

/// Declares the range of a property.
public struct RangeAnnotationValue: RangeAnnotation, ContributionAnnotation {
    public let term: any Node
    public let contributionProtocolName: String = "RangeTerm"
    public let contributionTypeName: String = "RangeAnnotationValue"

    public init(_ term: any Node) {
        self.term = term
    }
}

// MARK: - DSL

/// Declares the range of a property.
///
///     Range(RDFS.Literal)
public func Range(_ term: any Node) -> RangeAnnotationValue {
    RangeAnnotationValue(term)
}
