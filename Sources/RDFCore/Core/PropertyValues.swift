/// The values of a many-valued property of an individual.
///
/// A property has any number of values unless it is functional, so the
/// `@Ontology` macro exposes it as `PropertyValues` of its range:
/// `lion.hasHabitat` is a `PropertyValues<any Fauna.Habitat>`.
///
/// It is a view on the values the individual's ``Membership`` stores, and it
/// holds the individual's graph, so it keeps working after the individual
/// itself is released. Each change holds a lock for the whole change, so
/// concurrent `append` calls from many tasks all land. Iterating, ``values``
/// and the other reads see one consistent snapshot.
///
/// The values of a named individual are fixed; changing them stops the
/// program.
public struct PropertyValues<Value: Sendable>: Sendable, Sequence {
    private let store: ValueStore<Value>
    private let graph: IndividualGraph?

    /// The values of the requirement `key` names, stored in `membership`.
    ///
    /// The default implementations of class protocol requirements call it:
    /// `RDFCore.PropertyValues(\Self.hasHabitat, of: membership)`.
    public init<Root>(_ key: any KeyPath<Root, PropertyValues<Value>> & Sendable, of membership: Membership) {
        store = membership.store(for: key)
        graph = membership.graph
    }

    /// The values of a property that is no class protocol requirement,
    /// stored in `membership` under the property's term type. See
    /// ``Entity/propertyValues(of:)``.
    init(term: any Entity.Type, of membership: Membership) {
        store = membership.store(forTerm: term)
        graph = membership.graph
    }

    /// A snapshot of the values, in the order they were added.
    public var values: [Value] { store.values(in: graph) }

    /// The number of values.
    public var count: Int { store.count() }

    /// Whether the property has no values.
    public var isEmpty: Bool { count == 0 }

    /// The first value, if there is one.
    public var first: Value? { values.first }

    /// The last value, if there is one.
    public var last: Value? { values.last }

    /// Adds a value.
    public func append(_ value: Value) {
        store.append(contentsOf: [value])
    }

    /// Adds several values.
    public func append(contentsOf values: [Value]) {
        store.append(contentsOf: values)
    }

    /// Replaces every value with these.
    public func replace(with values: [Value]) {
        store.replace(with: values)
    }

    /// Removes the values that match.
    ///
    /// The lock is held while `shouldBeRemoved` runs, so `shouldBeRemoved` must not read or change
    /// this same property of this individual: the lock is not reentrant, and
    /// doing so deadlocks. Read what `shouldBeRemoved` needs before calling it.
    public func removeAll(where shouldBeRemoved: (Value) -> Bool) {
        update { $0.removeAll(where: shouldBeRemoved) }
    }

    /// Removes every value.
    public func removeAll() {
        store.replace(with: [])
    }

    /// Reads and changes the values in one atomic step.
    ///
    /// The lock is held while `body` runs, so `body` must not read or change
    /// this same property of this individual: the lock is not reentrant, and
    /// doing so deadlocks. Read what `body` needs before calling it.
    public func update<Result: Sendable>(_ body: (inout [Value]) -> Result) -> Result {
        store.update(in: graph, body)
    }

    /// Iterates over a snapshot of the values.
    public func makeIterator() -> IndexingIterator<[Value]> {
        values.makeIterator()
    }
}
