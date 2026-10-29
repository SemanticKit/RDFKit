/// An RDF dataset: one default graph and any number of named graphs.
///
/// RDF 1.2 Concepts §5 RDF Datasets: "An RDF dataset is a collection of RDF
/// graphs, and comprises: Exactly one default graph, being an RDF graph. The
/// default graph does not have a name and MAY be empty. Zero or more named
/// graphs. Each named graph is a pair consisting of an IRI or a blank node
/// (the graph name), and an RDF graph. Graph names are unique within an RDF
/// dataset."
///
/// A graph name is a ``SubjectTerm``, the node kind that is an IRI or a blank
/// node. Reading a name with no graph gives an empty graph, and setting a
/// name's graph to an empty graph keeps the name.
public struct Dataset: Hashable, Sendable {
    /// The default graph.
    public var defaultGraph: Graph

    /// The named graphs, by graph name.
    public var namedGraphs: [SubjectTerm: Graph]

    /// Creates a dataset.
    public init(defaultGraph: Graph = [], namedGraphs: [SubjectTerm: Graph] = [:]) {
        self.defaultGraph = defaultGraph
        self.namedGraphs = namedGraphs
    }

    /// The default graph when `name` is `nil`, otherwise the graph named
    /// `name`.
    public subscript(name: SubjectTerm?) -> Graph {
        get {
            guard let name else { return defaultGraph }
            return namedGraphs[name] ?? []
        }
        set {
            guard let name else { defaultGraph = newValue; return }
            namedGraphs[name] = newValue
        }
    }
}
