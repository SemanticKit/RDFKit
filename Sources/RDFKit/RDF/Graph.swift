import Foundation

/// An RDF graph is a set of triples with an optional graph name.
public protocol RDFGraph: CustomStringConvertible, Sendable {
    associatedtype TripleType: RDFTriple

    /// The optional graph name.
    var name: (any RDFNode)? { get }

    /// The graph triples.
    var triples: Set<TripleType> { get }

    /// Inserts a triple into the graph.
    mutating func insert(_ triple: TripleType) throws

    /// Removes a triple from the graph.
    mutating func remove(_ triple: TripleType) throws

    /// Returns whether the graph contains a triple.
    func contains(_ triple: TripleType) -> Bool

    /// Returns triples matching the supplied pattern.
    func match(subject: TripleType.Subject?, predicate: TripleType.Predicate?, object: TripleType.Object?) -> Set<TripleType>
}

/// Errors thrown by graph storage operations.
public enum RDFGraphError: Error, CustomStringConvertible {
    /// The subject was invalid.
    case invalidSubject

    /// The predicate was invalid.
    case invalidPredicate

    /// The triple already exists.
    case duplicateTriple

    public var description: String {
        switch self {
        case .invalidSubject:
            return "Subject must be IRI or BlankNode."
        case .invalidPredicate:
            return "Predicate must be an IRI."
        case .duplicateTriple:
            return "Triple already present in the graph."
        }
    }
}

extension RDFGraph {
    public func contains(_ triple: TripleType) -> Bool {
        triples.contains(triple)
    }

    public func match(
        subject: TripleType.Subject? = nil,
        predicate: TripleType.Predicate? = nil,
        object: TripleType.Object? = nil
    ) -> Set<TripleType> {
        triples.filter { triple in
            (subject == nil || triple.subject == subject!) &&
            (predicate == nil || triple.predicate == predicate!) &&
            (object == nil || triple.object == object!)
        }
    }

    public var description: String {
        triples.map(\.description).sorted().joined(separator: "\n")
    }
}

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
