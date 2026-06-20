import Foundation

// MARK: - Protocol

/// A descriptive comment.
///
/// From RDFS: Used to provide a human-readable description of a resource.
//public protocol CommentProtocol: TermContent {
//    /// The comment text.
//    var text: String { get }
//}

// MARK: - Concrete Type

/// A descriptive comment.
//public struct CommentAnnotationValue: CommentProtocol, ContributionAnnotation {
//    public let text: String
//    public let contributionProtocolName: String = "CommentedTerm"
//    public let contributionTypeName: String = "CommentAnnotationValue"
//
//    public init(_ text: String) {
//        self.text = text
//    }
//}

// MARK: - DSL

/// A descriptive comment for a term.
///
///     Comment("The class resource, everything.")
//public func Comment(_ text: String) -> CommentAnnotationValue {
//    CommentAnnotationValue(text)
//}
