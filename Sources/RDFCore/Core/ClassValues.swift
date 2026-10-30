/// The property values of one class that an individual stores: the values of
/// the properties whose domain is the class.
///
/// The `@Ontology` macro generates one for every class, `Fauna.AnimalValues`,
/// with an empty value for every property.
public protocol ClassValues: Sendable {
    /// Values with no property stated.
    init()
}

/// The property values of an individual's classes, one ``ClassValues`` for
/// each class that has properties.
///
/// An individual is in its classes and in all of their superclasses, and a
/// property is one property whichever class it is reached through. So an
/// individual typed with two classes that share a superclass stores that
/// superclass's values once. An individual keeps them in its
/// ``IndividualStorage``, `IndividualStorage<IndividualValues>`.
public struct IndividualValues: Sendable {
    private var values: [ObjectIdentifier: any Sendable] = [:]

    /// No values stated for any class.
    public init() {}

    /// Reads or changes the values of one class, the class whose values
    /// `body` takes.
    public mutating func withValues<Values: ClassValues, Result>(_ body: (inout Values) -> Result) -> Result {
        let key = ObjectIdentifier(Values.self)
        var classValues = values[key] as? Values ?? Values()
        let result = body(&classValues)
        values[key] = classValues
        return result
    }
}

/// An individual that stores the values of its classes in an
/// ``IndividualStorage`` of ``IndividualValues``.
///
/// The storing protocol `@Ontology` generates for a class,
/// `Fauna.AnimalStoring`, refines it and gives the class's properties their
/// accessors through ``withClassValues(_:)``. An individual of another
/// ontology or module typed with the class conforms to the storing protocol.
public protocol ClassValuesStoring: Resource {
    /// Reads or changes this individual's values of one class under its lock.
    func withClassValues<Values: ClassValues, Result: Sendable>(_ body: (inout Values) -> Result) -> Result
}
