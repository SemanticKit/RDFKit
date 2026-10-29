import Synchronization

/// The value of a functional property of an individual.
///
/// An `owl:FunctionalProperty` has at most one value, so the `@Ontology`
/// macro stores it as a `PropertyValue` of its range: `lion.hasDiet` is a
/// `PropertyValue<any Fauna.Diet>`.
///
/// The value is guarded by a mutex. Each method holds the lock for the whole
/// change; use ``update(_:)`` to read and change the value in one step.
public final class PropertyValue<Value: Sendable>: PropertyStorage {
    private let storage: Mutex<Value?>

    /// Creates the property with this value, or with none.
    public init(_ value: Value? = nil) {
        storage = Mutex(value)
    }

    /// The value, if the property has one.
    public var value: Value? { storage.withLock { $0 } }

    /// Sets the value, or removes it with `nil`.
    public func replace(with value: Value?) {
        storage.withLock { $0 = value }
    }

    /// Removes the value.
    public func removeAll() {
        // Release the value outside the lock: releasing an individual can
        // release others, which must not run while this lock is held.
        _ = storage.withLock { value in
            let removed = value
            value = nil
            return removed
        }
    }

    /// Reads and changes the value in one atomic step.
    public func update<Result: Sendable>(_ body: (inout Value?) -> Result) -> Result {
        storage.withLock { body(&$0) }
    }
}
