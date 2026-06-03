import Foundation

/// An RDF dataset containing one default graph and zero or more named graphs.
public protocol RDFDataset: Hashable, CustomStringConvertible, Sendable {
    associatedtype GraphType: RDFGraph & Hashable

    /// The default graph.
    var defaultGraph: GraphType { get }

    /// Named graphs indexed by IRI name.
    var namedGraphs: [IRI: GraphType] { get }

    /// Returns the named graph for an IRI.
    func graph(named name: IRI) -> GraphType?

    /// Returns the default graph or a named graph.
    func graph(_ name: IRI?) -> GraphType?

    /// Returns a dataset with a graph inserted.
    func inserting(_ graph: GraphType) throws -> Self

    /// Returns a dataset with a named graph removed.
    func removing(graph name: IRI) -> Self
}

/// Errors thrown while storing RDF datasets.
public enum RDFDatasetError: Error, CustomStringConvertible {
    /// A graph with the same name already exists.
    case duplicateGraphName

    /// A named graph did not use an IRI name.
    case invalidGraphName

    public var description: String {
        switch self {
        case .duplicateGraphName:
            return "A graph with that name already exists."
        case .invalidGraphName:
            return "Graph name must be an IRI."
        }
    }
}

extension RDFDataset {
    public func graph(named name: IRI) -> GraphType? {
        namedGraphs[name]
    }

    public func graph(_ name: IRI?) -> GraphType? {
        if let name {
            return namedGraphs[name]
        }
        return defaultGraph
    }

    public var description: String {
        ([defaultGraph.description] + namedGraphs.sorted(by: { $0.key < $1.key }).map { $0.value.description })
            .joined(separator: "\n")
    }
}

/// The default RDFKit dataset value.
public struct Dataset: RDFDataset {
    public typealias GraphType = Graph

    /// The default graph.
    public let defaultGraph: Graph

    /// Named graphs indexed by IRI name.
    public let namedGraphs: [IRI: Graph]

    /// Creates a dataset.
    public init(defaultGraph: Graph = Graph(), namedGraphs: [IRI: Graph] = [:]) {
        self.defaultGraph = defaultGraph
        self.namedGraphs = namedGraphs
    }

    public func inserting(_ graph: Graph) throws -> Dataset {
        guard let name = graph.name else {
            return Dataset(defaultGraph: defaultGraph.merging(with: graph), namedGraphs: namedGraphs)
        }
        guard let iri = name as? IRI else {
            throw RDFDatasetError.invalidGraphName
        }
        guard namedGraphs[iri] == nil else {
            throw RDFDatasetError.duplicateGraphName
        }
        var nextNamedGraphs = namedGraphs
        nextNamedGraphs[iri] = graph
        return Dataset(defaultGraph: defaultGraph, namedGraphs: nextNamedGraphs)
    }

    public func removing(graph name: IRI) -> Dataset {
        var nextNamedGraphs = namedGraphs
        nextNamedGraphs.removeValue(forKey: name)
        return Dataset(defaultGraph: defaultGraph, namedGraphs: nextNamedGraphs)
    }
}

extension Dataset {
    /// Returns a dataset containing triples from both datasets.
    public func merged(with other: Dataset) -> Dataset {
        Dataset.merged([self, other])
    }

    /// Returns one dataset containing triples from all datasets.
    public static func merged(_ datasets: [Dataset]) -> Dataset {
        var defaultGraph = Graph()
        var namedGraphs: [IRI: Graph] = [:]
        for dataset in datasets {
            defaultGraph = defaultGraph.merging(with: dataset.defaultGraph)
            for (name, graph) in dataset.namedGraphs {
                if let existing = namedGraphs[name] {
                    namedGraphs[name] = existing.merging(with: graph)
                } else {
                    namedGraphs[name] = graph
                }
            }
        }
        return Dataset(defaultGraph: defaultGraph, namedGraphs: namedGraphs)
    }
}
