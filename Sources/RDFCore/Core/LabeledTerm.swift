import Foundation

/// A term that has a human-readable label.
///
/// The macro generates this conformance when `Label("...")` appears
/// in the DSL body. The `label` property is computed from children.
public protocol LabeledTerm: OntologyTerm {}

extension LabeledTerm {
    public var label: String? {
        children.lazy
            .compactMap { $0 as? LabelAnnotationValue }
            .first?.text
    }
}
