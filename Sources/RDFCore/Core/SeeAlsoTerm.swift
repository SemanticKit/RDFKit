import Foundation

/// A term that has a see-also reference.
///
/// The macro generates this conformance when `SeeAlso("...")` appears
/// in the DSL body.
public protocol SeeAlsoTerm: OntologyTerm {}

extension SeeAlsoTerm {
    public var seeAlso: String? {
        children.lazy
            .compactMap { $0 as? SeeAlsoAnnotationValue }
            .first?.url
    }
}
