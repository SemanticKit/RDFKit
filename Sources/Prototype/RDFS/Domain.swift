import IRIKit

// MARK: - Domain

/// States that the declared property applies to instances of `Term`.
///
/// The related term is a Swift type, never an IRI:
/// `Domain(Animal)`.
public struct Domain<Term: Entity>: SemanticProperty, Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension Domain {
    public static var metadata: any ContentMetadata {
        Property.PropertyMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#domain",
            name: "domain",
            label: "domain",
            comment: "A domain of the subject property."
        )
    }
}
