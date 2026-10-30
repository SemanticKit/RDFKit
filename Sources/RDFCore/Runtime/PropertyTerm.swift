/// The term type `@Ontology` generates for a property it declares,
/// `Fauna.hasHabitat`, which writes the property's description.
///
/// A generated `encode(to:)` keys the property's values by its term type:
/// `PropertyKey(Fauna.hasHabitat.metadata)`.
public protocol PropertyTerm: Description {
    /// The boundary projection of the property: its IRI and documentation.
    static var metadata: any ContentMetadata { get }
}
