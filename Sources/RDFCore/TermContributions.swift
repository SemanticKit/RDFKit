import Foundation

// MARK: - Contribution Protocols
//
// Each protocol adds a specific capability to generated term types.
// The macro reads DSL annotations and generates conformances to these.
// Properties are computed from the `children` array — no stored state.
//
// ContentModifiers are the meta layer: they're applied in the DSL,
// and the macro reads them to determine which contributions to generate.

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

/// A term that has an RDF type assignment.
///
/// The macro generates this conformance when `Type(...)` appears
/// in the DSL body.
public protocol TypedTerm: OntologyTerm {}

extension TypedTerm {
    public var types: [any Node] {
        children.lazy
            .compactMap { $0 as? TypeAnnotationValue }
            .map(\.term)
    }

    /// The first type declaration, if any.
    public var type: (any Node)? { types.first }
}

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

/// A term that declares a superproperty.
///
/// The macro generates this conformance when `SubPropertyOf(...)` appears
/// in the DSL body.
public protocol SubPropertyOfTerm: OntologyTerm {}

extension SubPropertyOfTerm {
    public var subPropertyOf: (any Node)? {
        children.lazy
            .compactMap { $0 as? SubPropertyOfAnnotationValue }
            .first?.term
    }
}

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

/// A term that declares a range.
///
/// The macro generates this conformance when `Range(...)` appears
/// in the DSL body.
public protocol RangeTerm: OntologyTerm {}

extension RangeTerm {
    public var range: (any Node)? {
        children.lazy
            .compactMap { $0 as? RangeAnnotationValue }
            .first?.term
    }
}

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
