import Foundation

// MARK: - Protocol

/// Marks a term as deprecated.
///
/// From OWL: Indicates that an entity is deprecated.
public protocol OWLDeprecatedProtocol: TermContent {}

// MARK: - Concrete Type

/// Marks a term as deprecated.
public struct OWLDeprecatedAnnotationValue: OWLDeprecatedProtocol, ContributionAnnotation {
    public let contributionProtocolName: String = "DeprecatedTerm"
    public let contributionTypeName: String = "OWLDeprecatedAnnotationValue"

    public init() {}
}

// MARK: - DSL

/// Marks a term as deprecated in OWL.
///
///     OWLDeprecated()
public func OWLDeprecated() -> OWLDeprecatedAnnotationValue {
    OWLDeprecatedAnnotationValue()
}
