import Synchronization

/// The property values of one individual, as typed Swift values.
///
/// Every individual keeps its values here, whether `@Ontology` generated its
/// class from DSL or `RDFTranslatorPlugin` from RDF. Each property has a
/// ``PropertyValue`` type that holds its values, typed by the property's
/// range (`[any FOAF.Person]` for `foaf:knows`), and the storage holds one
/// value of each property type the individual has a value for. The
/// property's Swift type is the key, so a property is one property however
/// many of its domains, or of their subclasses, the individual is in, and
/// whichever ontology or module declares them.
///
/// Individuals are shared references, so the values are read and written
/// under a lock, and the individual is `Sendable` without an unchecked
/// conformance. No IRI is involved: the storage holds the Swift values, and
/// an encoder turns them into triples only when the individual leaves the
/// runtime.
public final class IndividualStorage: Sendable {
    private let values = Mutex(Values())

    /// No values stated for any property.
    public init() {}

    /// Reads or changes the value of one property, the property whose value
    /// `body` takes, under the lock.
    public func withValue<Value: PropertyValue, Result: Sendable>(_ body: (inout Value) -> Result) -> Result {
        values.withLock { values in values.withValue(body) }
    }

    /// Writes every property value stated, in the order the properties were
    /// first given a value.
    public func encode(to encoder: any Encoder) throws {
        for value in values.withLock({ $0.all }) {
            try value.encode(to: encoder)
        }
    }

    /// The values, keyed by their property's Swift type, in the order each
    /// property was first given one.
    private struct Values: Sendable {
        private var order: [ObjectIdentifier] = []
        private var values: [ObjectIdentifier: any PropertyValue] = [:]

        var all: [any PropertyValue] { order.compactMap { values[$0] } }

        mutating func withValue<Value: PropertyValue, Result>(_ body: (inout Value) -> Result) -> Result {
            let key = ObjectIdentifier(Value.self)
            var value = values[key] as? Value ?? Value()
            let result = body(&value)
            if values.updateValue(value, forKey: key) == nil { order.append(key) }
            return result
        }
    }
}
