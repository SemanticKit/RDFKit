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
    ///
    /// Setting or changing the value states the property's values anew: the
    /// literals a decoder kept for the property because they denote no value
    /// of its Swift type (``PropertyLiterals``), which the accessor cannot
    /// show, are no longer stated, so the individual writes only the values
    /// Swift gave it.
    public subscript<Value: PropertyValue>(_ property: Value.Type) -> Value {
        get {
            lock.withLock { values.value(Value.self) }
        }
        set {
            lock.withLock {
                values.set(newValue)
                values.remove(PropertyLiterals<Value>.self)
            }
        }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            // The value is taken out while it changes, so a reentrant access
            // to another property does not overlap an access to `values`.
            var value = values.value(Value.self)
            defer {
                values.set(value)
                values.remove(PropertyLiterals<Value>.self)
            }
            yield &value
        }
    }

    /// The literals stated for one property, kept because they denote no
    /// value of the property's Swift type: an ill-typed literal, one of a
    /// datatype with no Swift type, or one whose value is outside the range.
    public func keptLiterals<Value: PropertyValue>(of property: Value.Type) -> [Literal] {
        lock.withLock { values.value(PropertyLiterals<Value>.self).value }
    }

    /// States what a document gives one property whose range is a datatype
    /// with a Swift value type, as a decoder reads it: the values its
    /// literals denote, each of which writes back its literal, and the
    /// literals that denote none, kept as they are (``PropertyLiterals``).
    ///
    /// `RDFTranslatorPlugin` reads each literal with the range's value type
    /// while it translates, so the Swift it writes states the values as
    /// values, and only the literals that stay literals as ``Literal``s.
    public func state<Value: DatatypePropertyValue>(_ members: [Value.Member], keeping literals: [Literal] = [], for property: Value.Type) {
        var stated = Value()
        stated.value = members
        var kept = PropertyLiterals<Value>()
        kept.value = literals
        lock.withLock {
            if !stated.value.isEmpty { values.set(stated) }
            if !kept.value.isEmpty { values.set(kept) }
        }
    }

    /// Reads the value of one property from a decoder, and keeps it.
    public func decode(_ property: any (PropertyValue & Decodable).Type, from decoder: any Decoder) throws {
        try keep(property, decoder)
    }

    private func keep<Value: PropertyValue & Decodable>(_ property: Value.Type, _ decoder: any Decoder) throws {
        let value = try Value(from: decoder)
        // The literals the property's values do not hold, which the decoder
        // kept while the value read them.
        let objects = try decoder.container(keyedBy: PropertyKey.self).superDecoder(forKey: PropertyKey(Value.key))
        let literals = (objects as? any PropertyObjectsDecoder)?.keptLiterals ?? []
        lock.withLock {
            values.set(value)
            if !literals.isEmpty {
                var kept = PropertyLiterals<Value>()
                kept.value = literals
                values.set(kept)
            }
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

        mutating func remove<Value: PropertyValue>(_ type: Value.Type) {
            let key = ObjectIdentifier(type)
            guard values.removeValue(forKey: key) != nil else { return }
            order.removeAll { $0 == key }
        }
    }
}
