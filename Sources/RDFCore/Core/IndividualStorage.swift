import Synchronization

/// The property values of an individual, guarded by a mutex.
///
/// Every individual type the `@Ontology` macro generates keeps its property
/// values in one `IndividualStorage`. Individuals are shared references, so
/// their values are read and written under the lock, and the individual is
/// `Sendable` without any unchecked conformance.
public struct IndividualStorage<Values: Sendable>: ~Copyable, Sendable {
    private let mutex: Mutex<Values>

    /// Stores an individual's initial property values.
    public init(_ values: Values) {
        mutex = Mutex(values)
    }

    /// Reads or changes the property values while holding the lock.
    public borrowing func withLock<Result: Sendable>(_ body: (inout Values) -> Result) -> Result {
        mutex.withLock { values in body(&values) }
    }
}
