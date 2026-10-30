import Foundation

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
/// Individuals are shared references, so every access to a value holds the
/// storage's lock, and a change in place, `alice.knows.append(bob)`, holds
/// it from the read to the write: two threads appending to the same
/// property keep both values. No IRI is involved: the storage holds the
/// Swift values, and an encoder turns them into triples only when the
/// individual leaves the runtime.
public final class IndividualStorage: Sendable {
    /// Held for every access to `values`. It is recursive, so code that runs
    /// while one property changes in place can read the individual's other
    /// properties.
    private let lock = NSRecursiveLock()

    /// The values. Read and written only while `lock` is held.
    nonisolated(unsafe) private var values = Values()

    /// No values stated for any property.
    public init() {}

    /// The value of one property, the property whose value type is `Value`.
    ///
    /// Reading copies the value under the lock, and setting replaces it under
    /// the lock. Changing it in place holds the lock for the whole change.
    public subscript<Value: PropertyValue>(_ property: Value.Type) -> Value {
        get {
            lock.withLock { values.value(Value.self) }
        }
        set {
            lock.withLock { values.set(newValue) }
        }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            // The value is taken out while it changes, so a reentrant access
            // to another property does not overlap an access to `values`.
            var value = values.value(Value.self)
            defer { values.set(value) }
            yield &value
        }
    }

    /// Writes every property value stated, in the order the properties were
    /// first given a value.
    public func encode(to encoder: any Encoder) throws {
        for value in lock.withLock({ values.all }) {
            try value.encode(to: encoder)
        }
    }

    /// The values, keyed by their property's Swift type, in the order each
    /// property was first given one.
    private struct Values {
        private var order: [ObjectIdentifier] = []
        private var values: [ObjectIdentifier: any PropertyValue] = [:]

        var all: [any PropertyValue] { order.compactMap { values[$0] } }

        func value<Value: PropertyValue>(_ type: Value.Type) -> Value {
            values[ObjectIdentifier(type)] as? Value ?? Value()
        }

        mutating func set<Value: PropertyValue>(_ value: Value) {
            let key = ObjectIdentifier(Value.self)
            if values.updateValue(value, forKey: key) == nil { order.append(key) }
        }
    }
}
