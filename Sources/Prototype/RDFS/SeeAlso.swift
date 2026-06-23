
import IRIKit

// MARK: - SeeAlso

public struct SeeAlso: DocumentationProperty, Sendable {
    public typealias ID = IRI


    public var id: ID
    public var seeAlso: String

    public init(id: IRI, seeAlso: String) {
        self.id = id
        self.seeAlso = seeAlso
    }

    public init(_ value: String) {
        self.id = Self.metadata.id
        self.seeAlso = value
    }
}

// MARK: Generated Type Metadata

extension SeeAlso: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#seeAlso",
        name: "seeAlso",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/2000/01/rdf-schema#Resource",
        range: "http://www.w3.org/2000/01/rdf-schema#Resource",
        label: "seeAlso",
        comment: "Further information about the subject resource."
    )
}
