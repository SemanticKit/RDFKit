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
