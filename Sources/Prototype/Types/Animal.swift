import IRIKit

public struct Animal: Sendable {

    public typealias ID = IRI

    public var id: ID
    public var name: String
    public var hasHabitat: IRI
    public var hasDiet: IRI
    public var commonName: String
    public var scientificName: String

    public init(
        _ name: String,
        @EntityContentBuilder _ children: () -> Content
    ) {
        self.id = ""
        self.name = name
        self.hasHabitat = ""
        self.hasDiet = ""
        self.commonName = ""
        self.scientificName = ""
    }
}

// MARK: Generated Type Metadata

extension Animal: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Animal",
        name: "Animal",
        type: "https://fauna.example.org/ontology#Animal",
        label: "Animal",
        comment: "The class of all animals."
    )
}
