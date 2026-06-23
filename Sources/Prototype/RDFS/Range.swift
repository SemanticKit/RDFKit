import IRIKit

// MARK: - Range

public struct Range: SemanticProperty, Sendable {
    public typealias ID = IRI

    public var id: ID

    public init(id: IRI) {
        self.id = id
    }

    public init(_ type: any Entity.Type) {
        self.id = type.metadata.id
    }
}


// MARK: Generated Type Metadata

extension Range: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#range",
        name: "range",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        range: "http://www.w3.org/2000/01/rdf-schema#Class",
        label: "range",
        comment: "A range of the subject property."
    )
}
