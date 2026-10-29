import Synchronization

/// The individuals created together, and the owner of their lifetime.
///
/// Individuals are references, and properties link them in cycles: a lion
/// has the savanna as habitat, and the savanna is inhabited by the lion.
/// Each generated individual type is created in a graph,
/// `Fauna.PredatorIndividual(in: graph)`. The graph keeps its individuals
/// alive for as long as it lives, and when it is released it removes every
/// property value of every individual in it. That breaks every cycle, so the
/// individuals are freed once nothing else holds them. An individual still
/// held after its graph is gone keeps its identity but has no values.
///
/// Named individuals (`Fauna.carnivore`) belong to no graph: they are static
/// constants that live as long as the program.
public final class IndividualGraph: Sendable {
    private struct Members: Sendable {
        var individuals: [any Resource] = []
        var properties: [any PropertyStorage] = []
    }

    private let members = Mutex(Members())

    /// Creates an empty graph.
    public init() {}

    /// The individuals created in this graph, in the order they were created.
    public var individuals: [any Resource] {
        members.withLock { $0.individuals }
    }

    /// Adds an individual and the storage of its properties. Generated
    /// individual initializers call it.
    public func insert(_ individual: any Resource, properties: [any PropertyStorage]) {
        members.withLock { members in
            members.individuals.append(individual)
            members.properties.append(contentsOf: properties)
        }
    }

    deinit {
        let members = members.withLock { members in
            let taken = members
            members = Members()
            return taken
        }
        for property in members.properties {
            property.removeAll()
        }
    }
}
