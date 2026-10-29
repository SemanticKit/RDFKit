// MARK: - Example: Fauna.Habitat

/// An example of the type the macro generates for `Class("Habitat")`.
public struct Habitat: Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension Habitat: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Habitat",
        name: "Habitat",
        type: "http://www.w3.org/2000/01/rdf-schema#Class",
        label: "Habitat",
        comment: "The class of natural habitats."
    )
}
