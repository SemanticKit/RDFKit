import Synchronization

/// The graph that owns a set of individuals and the links between them.
///
/// Individuals are references, and properties link them in cycles: a lion
/// has the savanna as habitat, and the savanna is inhabited by the lion.
/// Each generated individual type is created in a graph,
/// `Fauna.PredatorIndividual(in: graph)`.
///
/// Each individual holds its graph, and the graph holds what its
/// individuals store, so the graph and all its individuals stay alive while
/// anything holds the graph, one of its individuals or a property view of
/// one. A function can create a graph, return one individual of it and drop
/// the graph: the individual keeps its values and everything they link to.
/// Once nothing holds any of them, the graph is released, empties every
/// store and so breaks every cycle, and everything is freed together.
///
/// Values link individuals of the same graph only; a value from another
/// graph stops the program. Named individuals (`Fauna.carnivore`) belong to
/// no graph: they are static constants with fixed values, shared by every
/// graph.
public final class IndividualGraph: Sendable {
    private let nodes = Mutex<[IndividualNode]>([])

    /// Creates an empty graph.
    public init() {}

    /// The individuals created in this graph, in the order they were created.
    public var individuals: [any Resource] {
        nodes.withLock { $0 }.map { $0.individual(in: self) }
    }

    /// Adds an individual created on a ``Membership`` in this graph.
    /// Generated individual initializers call it.
    public func insert(_ individual: some StoredIndividual) {
        let membership = individual.membership
        precondition(membership.graph === self, "An individual is inserted into the graph it was created in.")
        membership.node.adopt(individual)
        nodes.withLock { $0.append(membership.node) }
    }

    deinit {
        let nodes = nodes.withLock { nodes in
            let taken = nodes
            nodes = []
            return taken
        }
        for node in nodes {
            node.removeAllValues()
        }
    }
}
