import IRIKit

// MARK: - SubPropertyOf

/// States that the declared property is a subproperty of `Term`.
///
/// The related term is the generic argument, a Swift type, never an IRI:
/// `SubPropertyOf<Animal>()`.
public struct SubPropertyOf<Term: Entity>: SemanticProperty, Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension SubPropertyOf {
    public static var metadata: any ContentMetadata {
        Property.PropertyMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#subPropertyOf",
            name: "subPropertyOf",
            label: "subPropertyOf",
            comment: "The subject is a subproperty of a property."
        )
    }
}
