import IRIKit

// MARK: - Class Type

/// Declares a class. The macro generates a Swift type for it; that type, not
/// the name, is the class's identity.
public struct Class: ClassLike, Sendable {
    /// The declared local name, the spelling of the generated type.
    public var localName: String

    /// The declaration's annotations.
    public var content: [AnyEntity]

    public init(_ localName: String, @ClassBuilder _ children: () -> [AnyEntity]) {
        self.localName = localName
        self.content = children()
    }
}


// MARK: Generated Type Metadata

extension Class: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Class",
        name: "Class",
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
            case label
            case comment
        }

        public let id: IRI
        public let name: String
        public let label: String
        public let comment: String
    }
}
