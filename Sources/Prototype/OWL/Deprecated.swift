import IRIKit

// MARK: - Deprecated

public struct Deprecated: DocumentationProperty, Sendable {
    public typealias ID = IRI

    public var id: ID

    public init(id: IRI) {
        self.id = id
    }

    public init() {
        self.id = Self.metadata.id
    }
}


// MARK: Generated Type Metadata

extension Deprecated: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2002/07/owl#deprecated",
        name: "deprecated",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/2000/01/rdf-schema#Resource",
        range: "http://www.w3.org/2001/XMLSchema#boolean",
        label: "deprecated",
        comment: "The definition of the subject resource is deprecated."
    )
}
