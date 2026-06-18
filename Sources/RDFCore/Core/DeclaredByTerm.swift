import Foundation

/// A term that declares which ontology namespace it belongs to.
///
/// The macro generates this conformance when `.isDeclaredBy(namespace:)` is
/// chained on the term. When `namespace` is `nil`, the term belongs to the
/// parent ontology. When set to a different namespace, the term is imported
/// from that ontology.
public protocol DeclaredByTerm: OntologyTerm {}

extension DeclaredByTerm {
    /// The namespace this term is declared in, or `nil` for the parent ontology.
    public var declaredIn: Namespace? {
        children.lazy
            .compactMap { $0 as? IsDeclaredByAnnotation }
            .first?.namespace
    }
}
