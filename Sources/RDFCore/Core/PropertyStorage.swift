/// The values of one property of one individual.
///
/// Every property of an individual the `@Ontology` macro generates is stored
/// in a ``PropertyValues`` (many values) or a ``PropertyValue`` (at most one
/// value, for an `owl:FunctionalProperty`). Both are references guarded by a
/// mutex, so an individual is `Sendable` as checked by the compiler and every
/// change to a property, including a read-modify-write such as `append`, is
/// atomic.
public protocol PropertyStorage: AnyObject, Sendable {
    /// Removes every value. ``IndividualGraph`` calls it on each property of
    /// its individuals when it is released, which breaks every cycle among
    /// them.
    func removeAll()
}
