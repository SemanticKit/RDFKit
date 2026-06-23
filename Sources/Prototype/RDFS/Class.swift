import IRIKit

// MARK: - Class Type

public struct Class: ClassLike, Sendable {

    public typealias ID = IRI

    public var id: ID

    public init(_ name: String, @ClassBuilder _ children: () -> [AnyEntity]) {
        self.id = IRI(rawValue: "\(name)") ?? ""
    }
}


// MARK: Generated Type Metadata

extension Class: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Class",
        name: "Class",
        type: "http://www.w3.org/2000/01/rdf-schema#Class",
        label: "Class",
        comment: "The class of classes."
    )
}


// MARK: Generator Metadata Type

extension Class {
    public struct ClassMetadata: ContentMetadata {
        public typealias ID = IRI

        public enum CodingKeys: String, CodingKey, CaseIterable {
            case id
            case name
            case type
            case label
            case comment
        }

        public let id: IRI
        public let name: String
        public let type: IRI
        public let label: String
        public let comment: String
    }
}
