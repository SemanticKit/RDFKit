import Foundation

/// A term that has a descriptive comment.
///
/// The macro generates this conformance when `Comment("...")` appears
/// in the DSL body.
public protocol CommentedTerm: OntologyTerm {}

extension CommentedTerm {
    public var comment: String? {
        children.lazy
            .compactMap { $0 as? CommentAnnotationValue }
            .first?.text
    }
}
