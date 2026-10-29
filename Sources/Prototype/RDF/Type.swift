import IRIKit

// MARK: - Type

/// States that the declared term is an instance of `Term`.
///
/// The related term is a Swift type, never an IRI:
/// `Type(Animal)`.
public struct Type<Term: Entity>: SemanticProperty, Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension Type {
    public static var metadata: any ContentMetadata {
        Property.PropertyMetadata(
            id: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            name: "type",
            label: "type",
            comment: "The subject is an instance of a class."
        )
    }
}
