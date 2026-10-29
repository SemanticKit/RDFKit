import Synchronization

/// The property values of an individual, kept by property and guarded by a
/// mutex.
///
/// Every individual has one storage, its ``Resource/propertyValues``. The
/// values of a property are kept under the property's term type (see
/// ``PropertyTerm`` and ``PropertyKey``), so the storage holds the values of
/// properties from any ontology: `Foaf.knows` and `Cert.key` on the same
/// person. Values are found by their property's type, never by an IRI or a
/// name.
///
/// Individuals are shared references, so their values are read and written
/// under the lock, and the individual is `Sendable` without any unchecked
/// conformance.
public final class IndividualStorage: Sendable {
    /// The values of one property.
    private struct Values<Property: PropertyKey>: Sendable {
        var value: Property.Value
    }

    private let properties = Mutex<[any Sendable]>([])

    /// An individual with no property values.
    public init() {}

    /// The values of `property`, or ``PropertyKey/noValues`` when none are set.
    public subscript<Property: PropertyKey>(property: Property) -> Property.Value {
        get {
            properties.withLock { properties in
                for stored in properties {
                    if let values = stored as? Values<Property> { return values.value }
                }
                return Property.noValues
            }
        }
        set {
            properties.withLock { properties in
                let values = Values<Property>(value: newValue)
                if let index = properties.firstIndex(where: { $0 is Values<Property> }) {
                    properties[index] = values
                } else {
                    properties.append(values)
                }
            }
        }
    }
}
