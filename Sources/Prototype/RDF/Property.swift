import IRIKit


// MARK: - Property Type

/// Declares a property. Its domain and range are the `Domain<Term>` and
/// `Range<Term>` annotations in ``content``: Swift types, never IRIs.
public struct Property: ClassLike, Sendable {
    /// The declared local name, the spelling of the generated stored property.
    public var localName: String

    /// The declaration's annotations, including `Domain<Term>` and `Range<Term>`.
    public var content: [AnyEntity]

    public var label: String
    public var comment: String

    public init(
        _ localName: String,
        @PropertyBuilder _ children: () -> [AnyEntity]
    ) {
        self.localName = localName
        self.content = children()
        self.label = localName
        self.comment = ""

        for child in content {
            if let annotation = child as? Label {
                self.label = annotation.text
            }
            if let annotation = child as? Comment {
                self.comment = annotation.comment
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
            case label
            case comment
        }

        public let id: IRI
        public let name: String
        public let label: String
        public let comment: String
    }
}
