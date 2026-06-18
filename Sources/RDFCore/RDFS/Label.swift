import Foundation

// MARK: - Protocol

/// A human-readable label.
///
/// From RDFS: Used to provide a human-readable version of a resource's name.
public protocol LabelProtocol: TermContent {
    /// The label text.
    var text: String { get }
}

// MARK: - Concrete Type

/// A human-readable label.
public struct LabelAnnotationValue: LabelProtocol, ContributionAnnotation {
    public let text: String
    public let contributionProtocolName: String = "LabeledTerm"
    public let contributionTypeName: String = "LabelAnnotationValue"

    public init(_ text: String) {
        self.text = text
    }
}

// MARK: - DSL

/// A human-readable label for a term.
///
///     Label("Resource")
public func Label(_ text: String) -> LabelAnnotationValue {
    LabelAnnotationValue(text)
}
