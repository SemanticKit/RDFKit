
import IRIKit

public struct Type: SemanticProperty, Sendable {
    public typealias ID = IRI

    public var id: ID

    // Standard initializer
    public init(id: IRI) {
        self.id = id
    }

    // DSL convenience — takes an Entity.Type, extracts its IRI
    public init(_ type: any Entity.Type) {
        self.id = type.metadata.id
    }
}

// MARK: Generated Type Metadata

extension Type: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        name: "type",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/2000/01/rdf-schema#Resource",
        range: "http://www.w3.org/2000/01/rdf-schema#Class",
        label: "type",
        comment: "The subject is an instance of a class."
    )
}
