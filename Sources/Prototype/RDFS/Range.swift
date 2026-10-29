import IRIKit

// MARK: - Range

/// States that values of the declared property are instances of `Term`.
///
/// The related term is the generic argument, a Swift type, never an IRI:
/// `Range<Animal>()`.
public struct Range<Term: Entity>: SemanticProperty, Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension Range {
    public static var metadata: any ContentMetadata {
        Property.PropertyMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#range",
            name: "range",
            label: "range",
            comment: "A range of the subject property."
        )
    }
}
