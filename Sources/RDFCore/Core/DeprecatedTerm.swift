import Foundation

/// A term that is deprecated.
///
/// The macro generates this conformance when `Deprecated()` appears
/// in the DSL body, or when `.deprecated()` is chained on the term.
public protocol DeprecatedTerm: OntologyTerm {}

extension DeprecatedTerm {
    public var isDeprecated: Bool {
        children.contains { $0 is OWLDeprecatedAnnotationValue }
    }
}
