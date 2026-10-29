// MARK: - Example: Fauna.Diet

/// An example of the type the macro generates for `Class("Diet")`.
public struct Diet: Sendable {
    public init() {}
}


// MARK: Generated Type Metadata

extension Diet: Entity {
    public static let metadata: any ContentMetadata = Class.ClassMetadata(
        id: "https://fauna.example.org/ontology#Diet",
        name: "Diet",
        label: "Diet",
        comment: "The class of dietary classifications."
    )
}
