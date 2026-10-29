import IRIKit

// MARK: - SubClassOf

/// States that the declared class is a subclass of `Term`.
///
/// The related term is a Swift type, never an IRI:
/// `SubClassOf(Animal)`.
public struct SubClassOf<Term: Entity>: SemanticProperty, Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension SubClassOf {
    public static var metadata: any ContentMetadata {
        Property.PropertyMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#subClassOf",
            name: "subClassOf",
            label: "subClassOf",
            comment: "The subject is a subclass of a class."
        )
    }
}
