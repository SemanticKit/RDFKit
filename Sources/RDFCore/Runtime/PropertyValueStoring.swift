/// An individual that keeps its property values in an ``IndividualStorage``.
///
/// The storing protocol generated for a property, `FOAF.knowsStoring`,
/// refines it and gives the property its accessor through
/// ``withPropertyValue(_:)``. The storing protocol of a class,
/// `FOAF.PersonStoring`, refines the class's protocol and the storing
/// protocols of the properties its members can have and of its
/// superclasses. Every individual's class conforms to the storing protocols
/// of its classes, whichever ontology or module declares them, so an
/// individual typed with classes of several vocabularies has all of their
/// properties, each once.
public protocol PropertyValueStoring: Resource {
    /// The individual's property values.
    var storage: IndividualStorage { get }
}

extension PropertyValueStoring {
    /// Reads or changes this individual's value of one property under its lock.
    public func withPropertyValue<Value: PropertyValue, Result: Sendable>(_ body: (inout Value) -> Result) -> Result {
        storage.withValue(body)
    }
}
