/// The value of one property that an individual stores.
///
/// The `@Ontology` macro generates one for every property that is a
/// requirement of a class, `Fauna.hasHabitatValue`, holding the property's
/// values and starting empty.
public protocol PropertyValue: Sendable {
    /// No value stated.
    init()
}

/// The property values of an individual, one ``PropertyValue`` for each
/// property it has.
///
/// An individual is in its classes and in all of their superclasses, and a
/// property is one property whichever of its domains it is reached
/// through. The values of an individual typed with classes of other
/// ontologies are kept here, in its ``IndividualStorage``, because the
/// ontology that declares the individual cannot see those classes'
/// properties: each property's storing protocol reads and writes its own
/// value through ``PropertyValueStoring/withPropertyValue(_:)``.
public struct IndividualValues: Sendable {
    private var values: [ObjectIdentifier: any Sendable] = [:]

    /// No values stated for any property.
    public init() {}

    /// Reads or changes the value of one property, the property whose value
    /// `body` takes.
    public mutating func withValue<Value: PropertyValue, Result>(_ body: (inout Value) -> Result) -> Result {
        let key = ObjectIdentifier(Value.self)
        var value = values[key] as? Value ?? Value()
        let result = body(&value)
        values[key] = value
        return result
    }
}

/// An individual that stores its property values in an
/// ``IndividualStorage`` of ``IndividualValues``.
///
/// The storing protocol `@Ontology` generates for a property,
/// `Fauna.hasHabitatStoring`, refines it and gives the property its
/// accessors through ``withPropertyValue(_:)``. The storing protocol of a
/// class, `Fauna.AnimalStoring`, refines the storing protocols of the
/// properties in its domain and of its superclasses. An individual of
/// another ontology or module typed with the class conforms to it.
public protocol PropertyValueStoring: Resource {
    /// Reads or changes this individual's value of one property under its lock.
    func withPropertyValue<Value: PropertyValue, Result: Sendable>(_ body: (inout Value) -> Result) -> Result
}
