import IRIKit

// MARK: - SubPropertyOf

public struct SubPropertyOf: SemanticProperty, Sendable {
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

extension SubPropertyOf: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#subPropertyOf",
        name: "subPropertyOf",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        range: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        label: "subPropertyOf",
        comment: "The subject is a subproperty of a property."
    )
}
