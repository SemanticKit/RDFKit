import IRIKit

// MARK: - Datatype Type

/// Declares a datatype. The macro generates a Swift type for it; that type,
/// not the name, is the datatype's identity.
public struct Datatype: ClassLike, Sendable {
    /// The declared local name, the spelling of the generated type.
    public var localName: String

    /// The declaration's annotations.
    public var content: [AnyEntity]

    public init(
        _ localName: String,
        @DatatypeBuilder _ children: () -> [AnyEntity]
    ) {
        self.localName = localName
        self.content = children()
    }
}

// MARK: Generated Type Metadata

extension Datatype: Entity {
    public static let metadata: any ContentMetadata = Datatype.DatatypeMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#Datatype",
        name: "Datatype",
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
            case label
            case comment
        }

        public let id: IRI
        public let name: String
        public let label: String
        public let comment: String
    }
}
