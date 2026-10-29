/// The properties one ontology gives the individuals of one class.
///
/// The `@Ontology` macro generates a final class conforming to `PropertySet`
/// for each class it declares (`Fauna.AnimalProperties`, holding
/// `hasHabitat`, `hasDiet`, ...), and one for the properties it declares for
/// other ontologies' classes (`RDFS.ExtendingProperties`, holding
/// `rdfs:domain` and `rdfs:range` of an `rdf:Property`). Each property is a
/// ``PropertyValues`` or ``PropertyValue``.
///
/// An individual keeps one instance of each set it needs in its
/// ``IndividualProperties``, so every class an individual belongs to,
/// through any path of subclasses, reads the same values.
public protocol PropertySet: PropertyStorage {
    /// Creates the set with no values.
    init()
}
