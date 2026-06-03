import Foundation

/// The default RDFKit graph value.
public struct Graph: RDFGraph, Hashable, Sendable {
    public typealias TripleType = Triple<AnyRDFSubject, AnyRDFObject>

    /// The optional graph name.
    public let name: (any RDFNode)?

    /// The graph triples.
    public private(set) var triples: Set<TripleType> = []

    /// Creates an empty default graph.
    public init() {
        self.name = nil
    }

    /// Creates an empty graph with an optional name.
    public init(name: (any RDFNode)?) throws {
        if let name {
            guard name is IRI || name is BlankNode else {
                throw RDFTermError.invalidGraphName
            }
        }
        self.name = name
    }

    public mutating func insert(_ triple: TripleType) throws {
        guard !triples.contains(triple) else {
            throw RDFGraphError.duplicateTriple
        }
        triples.insert(triple)
    }

    public mutating func remove(_ triple: TripleType) throws {
        triples.remove(triple)
    }

    public static func == (lhs: Graph, rhs: Graph) -> Bool {
        lhs.name.map { AnyHashable($0) } == rhs.name.map { AnyHashable($0) } && lhs.triples == rhs.triples
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name.map { AnyHashable($0) })
        hasher.combine(triples)
    }
}

extension Graph {
    /// Returns a graph containing triples from both graphs.
    public func merged(with other: Graph) -> Graph {
        merging(with: other)
    }

    /// Returns a graph containing triples from both graphs.
    public func merging(with other: Graph) -> Graph {
        var merged = self
        for triple in other.triples {
            merged.triples.insert(triple)
        }
        return merged
    }
}
