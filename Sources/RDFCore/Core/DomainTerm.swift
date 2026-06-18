import Foundation

/// A term that declares a domain.
///
/// The macro generates this conformance when `Domain(...)` appears
/// in the DSL body.
public protocol DomainTerm: OntologyTerm {}

extension DomainTerm {
    public var domain: (any Node)? {
        children.lazy
            .compactMap { $0 as? DomainAnnotationValue }
            .first?.term
    }
}
