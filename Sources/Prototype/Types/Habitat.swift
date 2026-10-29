// MARK: - Example: Fauna.Habitat

/// An example of the protocol the macro generates for `Class("Habitat")`.
public protocol Habitat: AnyObject, Sendable {}

/// An example of the individual type the macro generates for
/// `Class("Habitat")`. It has no properties, so it stores nothing; each
/// instance is a distinct individual.
public final class HabitatIndividual: Habitat {
    public init() {}
}


// MARK: Generated Type Metadata

extension HabitatIndividual: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Habitat",
        name: "Habitat",
        label: "Habitat",
        comment: "The class of natural habitats."
    )
}
