import Synchronization

/// The values of a many-valued property of an individual.
///
/// A property has any number of values unless it is functional, so the
/// `@Ontology` macro stores it as `PropertyValues` of its range:
/// `lion.hasHabitat` is a `PropertyValues<any Fauna.Habitat>`.
///
/// The values are guarded by a mutex. Each method holds the lock for the
/// whole change, so concurrent `append` calls from many tasks all land.
/// Iterating, ``values`` and the other reads see one consistent snapshot.
public final class PropertyValues<Value: Sendable>: PropertyStorage, Sequence {
    private let storage: Mutex<[Value]>

    /// Creates the property with these values.
    public init(_ values: [Value] = []) {
        storage = Mutex(values)
    }

    /// A snapshot of the values, in the order they were added.
    public var values: [Value] { storage.withLock { $0 } }

    /// The number of values.
    public var count: Int { storage.withLock { $0.count } }

    /// Whether the property has no values.
    public var isEmpty: Bool { storage.withLock { $0.isEmpty } }

    /// The first value, if there is one.
    public var first: Value? { storage.withLock { $0.first } }

    /// The last value, if there is one.
    public var last: Value? { storage.withLock { $0.last } }

    /// Adds a value.
    public func append(_ value: Value) {
        storage.withLock { $0.append(value) }
    }

    /// Adds several values.
    public func append(contentsOf values: [Value]) {
        storage.withLock { $0.append(contentsOf: values) }
    }

    /// Replaces every value with these.
    public func replace(with values: [Value]) {
        storage.withLock { $0 = values }
    }

    /// Removes the values that match.
    public func removeAll(where shouldBeRemoved: (Value) -> Bool) {
        storage.withLock { $0.removeAll(where: shouldBeRemoved) }
    }

    /// Removes every value.
    public func removeAll() {
        // Release the values outside the lock: releasing an individual can
        // release others, which must not run while this lock is held.
        _ = storage.withLock { values in
            let removed = values
            values = []
            return removed
        }
    }

    /// Reads and changes the values in one atomic step.
    public func update<Result: Sendable>(_ body: (inout [Value]) -> Result) -> Result {
        storage.withLock { body(&$0) }
    }

    /// Iterates over a snapshot of the values.
    public func makeIterator() -> IndexingIterator<[Value]> {
        values.makeIterator()
    }
}
