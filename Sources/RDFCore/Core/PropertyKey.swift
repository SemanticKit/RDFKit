/// The key under which an individual keeps the values of one property.
///
/// A ``PropertyTerm`` is its own key. The few properties whose term type is
/// an alias of an RDFCore annotation, such as `rdfs:subClassOf`, are kept
/// under a key type the `@Ontology` macro generates for them.
public protocol PropertyKey: Sendable {
    /// The values one subject has for the property: an array of the range
    /// type, or an optional for an `owl:FunctionalProperty`.
    associatedtype Value: Sendable

    /// The value of a subject that has no values for the property: `[]`, or
    /// `nil` for a functional property.
    static var noValues: Value { get }

    /// The key.
    init()
}
