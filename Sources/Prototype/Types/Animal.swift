// MARK: - Example: Fauna.Animal

/// An example of the type the macro generates for `Class("Animal")`.
///
/// Relationships are typed by their range: `hasHabitat` is a ``Habitat``,
/// not an IRI. The IRI exists only in ``metadata``, for the boundary.
public struct Animal: Sendable {
    public var hasHabitat: Habitat
    public var hasDiet: Diet
    public var commonName: String
    public var scientificName: String

    public init(
        habitat: Habitat,
        diet: Diet,
        commonName: String,
        scientificName: String
    ) {
        self.hasHabitat = habitat
        self.hasDiet = diet
        self.commonName = commonName
        self.scientificName = scientificName
    }
}


// MARK: Generated Type Metadata

extension Animal: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Animal",
        name: "Animal",
        label: "Animal",
        comment: "The class of all animals."
    )
}
