
import IRIKit

// MARK: - Comment

public struct Comment: DocumentationProperty, Sendable {
    public typealias ID = IRI
    public typealias Metadata = any ContentMetadata

    public var id: ID
    public var comment: String

    public init(id: IRI, comment: String) {
        self.id = id
        self.comment = comment
    }

    public init(_ value: String) {
        self.id = Self.metadata.id
        self.comment = value
    }
}


// MARK: Generated Type Metadata

extension Comment: Entity {
    public static let metadata: any ContentMetadata = Property.PropertyMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#comment",
        name: "comment",
        type: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        domain: "http://www.w3.org/2000/01/rdf-schema#Resource",
        range: "http://www.w3.org/2000/01/rdf-schema#Literal",
        label: "comment",
        comment: "A description of the subject resource."
    )
}
