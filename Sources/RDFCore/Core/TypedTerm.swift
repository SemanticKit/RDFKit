import Foundation

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
