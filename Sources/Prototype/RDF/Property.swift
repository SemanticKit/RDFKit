import IRIKit


// MARK: - Property Type

public struct Property: ClassLike, Sendable {
    public typealias ID = IRI

    public var id: ID
    public var domain: IRI
    public var range: IRI
    public var label: String
    public var comment: String

    public init(
        _ name: String,
        @PropertyBuilder _ children: () -> [AnyEntity]
    ) {
        self.id = IRI(rawValue: "\(name)") ?? ""
        self.domain = ""
        self.range = ""
        self.label = name
        self.comment = ""

        let content = children()
        for child in content {
            if let prop = child as? Domain {
                self.domain = prop.id
            }
            if let prop = child as? Range {
                self.range = prop.id
            }
            if let prop = child as? Label {
                self.label = prop.id.rawValue
            }
            if let prop = child as? Comment {
                self.comment = prop.comment
            }
        }
    }
}


// MARK: Generated Type Metadata

extension Property: Entity {
    // Property IS a class — uses Class.Metadata for its own creation
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "http://www.w3.org/1999/02/22-rdf-syntax-ns#Property",
        name: "Property",
        type: "http://www.w3.org/2000/01/rdf-schema#Class",
        label: "Property",
        comment: "The class of RDF properties."
    )
}


// MARK: Generator Metadata Type

extension Property {
    // Metadata type for things declared AS properties
    public struct PropertyMetadata: ContentMetadata {
        public typealias ID = IRI

        public enum CodingKeys: String, CodingKey, CaseIterable {
            case id
            case name
            case type
            case domain
            case range
            case label
            case comment
        }

        public let id: IRI
        public let name: String
        public let type: IRI
        public let domain: IRI
        public let range: IRI
        public let label: String
        public let comment: String
    }
}
