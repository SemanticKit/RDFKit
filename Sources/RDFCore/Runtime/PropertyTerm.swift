/// The term type `@Ontology` generates for a property it declares,
/// `Fauna.hasHabitat`, which writes the property's description.
///
/// A generated `encode(to:)` keys the property's values by its declared key:
/// `PropertyKey(Fauna.hasHabitat.key)`.
public protocol PropertyTerm: Description {
    /// The declared key of the property.
    static var key: TermKey { get }
}
