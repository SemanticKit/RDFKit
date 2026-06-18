import Foundation

// MARK: - Protocol

/// A reference to related information.
///
/// From RDFS: Used to indicate a resource that might provide additional
/// information about the subject resource.
public protocol SeeAlsoProtocol: TermContent {
    /// The reference URL.
    var url: String { get }
}

// MARK: - Concrete Type

/// A reference to related information.
public struct SeeAlsoAnnotationValue: SeeAlsoProtocol, ContributionAnnotation {
    public let url: String
    public let contributionProtocolName: String = "SeeAlsoTerm"
    public let contributionTypeName: String = "SeeAlsoAnnotationValue"

    public init(_ url: String) {
        self.url = url
    }
}

// MARK: - DSL

/// A reference to related information.
///
///     SeeAlso("https://www.w3.org/TR/rdf12-concepts/")
public func SeeAlso(_ url: String) -> SeeAlsoAnnotationValue {
    SeeAlsoAnnotationValue(url)
}
