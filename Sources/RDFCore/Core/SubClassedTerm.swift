import Foundation

/// A term that declares a superclass.
///
/// The macro generates this conformance when `SubClassOf(...)` appears
/// in the DSL body.
public protocol SubClassedTerm: OntologyTerm {}

extension SubClassedTerm {
    public var subClassOf: (any Node)? {
        children.lazy
            .compactMap { $0 as? SubClassOfAnnotationValue }
            .first?.term
    }
}
