import IRIKit

// MARK: - Datatype Type

public struct Datatype: ClassLike, Sendable {
    public typealias ID = IRI

    public var id: ID

    public init(
        _ name: String,
        @DatatypeBuilder _ children: () -> [AnyEntity]
    ) {
        self.id = IRI(rawValue: "\(name)") ?? ""
    }
}

// MARK: Generated Type Metadata

extension Datatype: Entity {
    public static let metadata: any ContentMetadata = Datatype.DatatypeMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Datatype",
        name: "Datatype",
        type: "http://www.w3.org/2000/01/rdf-schema#Class",
        subClassOf: "http://www.w3.org/2000/01/rdf-schema#Class",
        label: "Datatype",
        comment: "The class of RDF datatypes."
    )
}

// MARK: Generator Metadata Type

extension Datatype {
    public struct DatatypeMetadata: ContentMetadata {
        public typealias ID = IRI

        public enum CodingKeys: String, CodingKey, CaseIterable {
            case id
            case name
            case type
            case subClassOf
            case label
            case comment
        }

        public let id: IRI
        public let name: String
        public let type: IRI
        public let subClassOf: IRI
        public let label: String
        public let comment: String
    }
}
