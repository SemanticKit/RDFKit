/// An individual's place in its graph: the store of its property values.
///
/// Every individual of a generated individual type holds its membership,
/// and so holds its graph: the graph, and every individual in it, stays
/// alive while anything holds one of its individuals or a property view of
/// one. `let names = lion.commonName` keeps the lion's values after `lion`
/// is gone.
///
/// The membership of a named individual belongs to no graph, and its values
/// are fixed.
public struct Membership: Sendable {
    /// The graph that owns the individual, or `nil` for a named individual.
    public let graph: IndividualGraph?

    let node: IndividualNode

    private init(graph: IndividualGraph?, node: IndividualNode) {
        self.graph = graph
        self.node = node
    }

    init(graph: IndividualGraph, node: IndividualNode) {
        self.init(graph: Optional(graph), node: node)
    }

    /// A membership in `graph`.
    ///
    /// A generated individual initializer calls it, then
    /// ``IndividualGraph/insert(_:)``. `make` creates an object for the
    /// individual on this membership when one of its values is read after
    /// every object for it has been released.
    public init(in graph: IndividualGraph, make: @escaping @Sendable (Membership) -> any StoredIndividual) {
        self.init(graph: graph, node: IndividualNode(graph: graph, make: make))
    }

    /// The membership of a named individual: no graph, and fixed values.
    public static func fixed() -> Membership {
        Membership(graph: nil, node: IndividualNode(graph: nil, make: nil))
    }

    /// The store of the property a requirement's key path names.
    func store<Value: Sendable>(for key: any AnyKeyPath & Sendable) -> ValueStore<Value> {
        node.store(for: .requirement(key))
    }

    /// The store of a property, by its term type.
    func store<Value: Sendable>(forTerm term: any Entity.Type) -> ValueStore<Value> {
        node.store(for: .term(term))
    }
}
