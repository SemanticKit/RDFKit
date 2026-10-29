import Synchronization

/// The part of an individual its graph owns: the stores of its properties.
///
/// Values link nodes, not individual objects, and the graph owns the nodes,
/// so cycles among individuals are cycles among nodes, which the graph breaks
/// when it is released. The individual object is a handle on its node: it
/// holds the node and the graph, and the node remembers it weakly. Reading a
/// value gives back the object while anything holds it, and otherwise makes
/// a new object of the same type on the same node.
///
/// Each store is created the first time its property is read. A property
/// that is a class protocol requirement is stored under the key path of the
/// requirement, so a property inherited along two paths
/// (`Fauna.Mesopredator` is a predator and a prey, both animals) has one
/// store. A property whose domain is another ontology's class, or that has
/// no domain, is stored under its ``PropertyTerm``: `cert:key` on a
/// `foaf:Person` is kept under `Cert.key`.
final class IndividualNode: Sendable {
    private struct State {
        weak var individual: (any StoredIndividual)?
        var stores: [StoreKey: any PropertyStorage] = [:]
    }

    /// What a store is kept under: the key path of a class protocol
    /// requirement, or a property term. Keys of different types are never
    /// equal, so a requirement and a term never share a store.
    private struct StoreKey: Hashable, Sendable {
        let key: any Hashable & Sendable

        static func == (lhs: Self, rhs: Self) -> Bool {
            AnyHashable(lhs.key) == AnyHashable(rhs.key)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(AnyHashable(key))
        }
    }

    /// The graph the node belongs to, or `nil` for a named individual.
    let graph: ObjectIdentifier?

    private let make: (@Sendable (Membership) -> any StoredIndividual)?
    private let state = Mutex(State())

    init(graph: IndividualGraph?, make: (@Sendable (Membership) -> any StoredIndividual)?) {
        self.graph = graph.map(ObjectIdentifier.init)
        self.make = make
    }

    /// The store for a requirement's key path or a property term, created
    /// empty the first time.
    func store<Value: Sendable>(for key: any Hashable & Sendable) -> ValueStore<Value> {
        let key = StoreKey(key: key)
        return state.withLock { state in
            if let existing = state.stores[key] {
                guard let store = existing as? ValueStore<Value> else {
                    preconditionFailure("A property's store holds the property's value type.")
                }
                return store
            }
            let store = ValueStore<Value>(graph: graph)
            state.stores[key] = store
            return store
        }
    }

    /// The individual object of this node in `graph`.
    func individual(in graph: IndividualGraph) -> any StoredIndividual {
        state.withLock { state in
            if let individual = state.individual { return individual }
            guard let make else { preconditionFailure("A node in a graph can make its individual.") }
            let individual = make(Membership(graph: graph, node: self))
            state.individual = individual
            return individual
        }
    }

    /// Records the object created for this node.
    func adopt(_ individual: any StoredIndividual) {
        state.withLock { $0.individual = individual }
    }

    /// Empties every store. ``IndividualGraph`` calls it when it is released.
    func removeAllValues() {
        let stores = state.withLock { state in
            let taken = Array(state.stores.values)
            state.stores = [:]
            return taken
        }
        // Release the values outside the lock: releasing a node can release
        // the stores of other nodes.
        for store in stores {
            store.removeAll()
        }
    }
}
