import Synchronization

/// The stored values of one property of one individual.
///
/// An individual's ``Membership`` keeps a `ValueStore` for each property,
/// which ``PropertyValues`` and ``PropertyValue`` expose. A store keeps an
/// individual of its own graph as that individual's ``IndividualNode``, not
/// as the object, so values link individuals without the objects holding
/// each other: an individual object is freed as soon as nothing outside the
/// graph holds it, and reading the value again gives back the individual
/// (the same object, while anything still holds it). Named individuals and
/// literals are stored as they are.
///
/// The values are guarded by a mutex, and each change holds the lock for the
/// whole change.
///
/// A store belongs to the graph of its individual, and a value that is an
/// individual of another graph is rejected: a graph owns the lifetime of
/// everything its individuals link to. The store of a named individual
/// belongs to no graph and is fixed: its values never change.
final class ValueStore<Value: Sendable>: PropertyStorage {
    enum Slot: Sendable {
        case value(Value)
        case member(IndividualNode)
    }

    private let slots = Mutex<[Slot]>([])

    /// The graph the store belongs to, or `nil` for a fixed store.
    private let graph: ObjectIdentifier?

    /// An empty store in a graph, or a fixed one with `nil`.
    init(graph: ObjectIdentifier?) {
        self.graph = graph
    }

    /// Whether the values can never change: the store of a named individual.
    var isFixed: Bool { graph == nil }

    // MARK: - Reading

    func values(in graph: IndividualGraph?) -> [Value] {
        let slots = slots.withLock { $0 }
        return slots.map { Self.value(of: $0, in: graph) }
    }

    func count() -> Int {
        slots.withLock { $0.count }
    }

    // MARK: - Changing

    func append(contentsOf values: [Value]) {
        let added = slots(for: values)
        slots.withLock { $0.append(contentsOf: added) }
    }

    func replace(with values: [Value]) {
        let replacement = slots(for: values)
        // Release the old values outside the lock.
        _ = slots.withLock { slots in
            let removed = slots
            slots = replacement
            return removed
        }
    }

    func update<Result: Sendable>(in graph: IndividualGraph?, _ body: (inout [Value]) -> Result) -> Result {
        guard let identifier = self.graph else { preconditionFailure(Self.fixedMessage) }
        let (result, removed) = slots.withLock { slots in
            var values = slots.map { Self.value(of: $0, in: graph) }
            let result = body(&values)
            let removed = slots
            slots = values.map { Self.slot(for: $0, in: identifier) }
            return (result, removed)
        }
        // Release the old values outside the lock.
        _ = removed
        return result
    }

    /// Removes every value.
    func removeAll() {
        // Release the values outside the lock: releasing a node can release
        // the stores of other nodes.
        _ = slots.withLock { slots in
            let removed = slots
            slots = []
            return removed
        }
    }

    // MARK: - Slots

    private static var fixedMessage: String {
        "A named individual's property values are fixed: they are the same in every graph and cannot change."
    }

    private func slots(for values: [Value]) -> [Slot] {
        guard let identifier = graph else { preconditionFailure(Self.fixedMessage) }
        return values.map { Self.slot(for: $0, in: identifier) }
    }

    private static func slot(for value: Value, in graph: ObjectIdentifier) -> Slot {
        guard let individual = value as? any StoredIndividual,
              let valueGraph = individual.membership.graph else { return .value(value) }
        precondition(
            ObjectIdentifier(valueGraph) == graph,
            "A property value must be an individual of the same graph: a graph owns the lifetime of everything its individuals link to."
        )
        return .member(individual.membership.node)
    }

    private static func value(of slot: Slot, in graph: IndividualGraph?) -> Value {
        switch slot {
        case .value(let value):
            return value
        case .member(let node):
            // A member slot exists only in a graph's store, and the view that
            // reads it holds that graph.
            guard let graph, let value = node.individual(in: graph) as? Value else {
                preconditionFailure("An individual's value does not have the property's range.")
            }
            return value
        }
    }
}
