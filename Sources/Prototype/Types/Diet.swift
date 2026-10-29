// MARK: - Example: Fauna.Diet

/// An example of the protocol the macro generates for `Class("Diet")`.
public protocol Diet: AnyObject, Sendable {}

/// An example of the individual type the macro generates for
/// `Class("Diet")`. It has no properties, so it stores nothing; each
/// instance is a distinct individual.
public final class DietIndividual: Diet {
    public init() {}
}


// MARK: Generated Type Metadata

extension DietIndividual: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Diet",
        name: "Diet",
        label: "Diet",
        comment: "The class of dietary classifications."
    )
}
