import IRIKit

/// An RDF graph: a set of triples.
///
/// RDF 1.2 Concepts §3 RDF Graphs: "An RDF graph is a set of RDF triples."
/// A graph holds each triple once, and two graphs are equal when they hold
/// the same triples, whatever order they were added in. Graphs that differ
/// only in the identifiers of their blank nodes are isomorphic
/// (``isIsomorphic(to:)``), not equal.
///
/// Iterating a graph gives its triples in the order they were first
/// inserted, so a decoded document encodes back in its own order.
///
/// A graph is how RDF data crosses the boundary: decoders produce one from a
/// document, and encoders write one. App code works with generated types,
/// not with graphs.
///
///     var graph: Graph = []
///     graph.insert(Triple(subject: .iri(alice), predicate: knows, object: .iri(bob)))
public struct Graph: SetAlgebra, RandomAccessCollection, Hashable, Sendable, CustomStringConvertible {
    /// The triples of a graph.
    public typealias Element = Triple<SubjectTerm, ObjectTerm>

    public typealias Index = Int

    /// The triples in insertion order.
    private var ordered: [Element]

    /// The same triples, for membership.
    private var members: Set<Element>

    /// Creates an empty graph.
    public init() {
        ordered = []
        members = []
    }

    // MARK: Collection

    public var startIndex: Int { ordered.startIndex }

    public var endIndex: Int { ordered.endIndex }

    public subscript(position: Int) -> Element { ordered[position] }

    public var count: Int { ordered.count }

    public var isEmpty: Bool { ordered.isEmpty }

    // MARK: Equality

    public static func == (lhs: Graph, rhs: Graph) -> Bool {
        lhs.members == rhs.members
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(members)
    }

    // MARK: SetAlgebra

    public func contains(_ triple: Element) -> Bool {
        members.contains(triple)
    }

    public func union(_ other: Graph) -> Graph {
        var result = self
        result.formUnion(other)
        return result
    }

    public func intersection(_ other: Graph) -> Graph {
        var result = self
        result.formIntersection(other)
        return result
    }

    public func symmetricDifference(_ other: Graph) -> Graph {
        var result = self
        result.formSymmetricDifference(other)
        return result
    }

    @discardableResult
    public mutating func insert(_ triple: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let result = members.insert(triple)
        if result.inserted { ordered.append(triple) }
        return result
    }

    /// Removes `triple` from the graph. This is O(*n*) in the graph's size,
    /// because the graph also keeps its triples' insertion order.
    @discardableResult
    public mutating func remove(_ triple: Element) -> Element? {
        guard let removed = members.remove(triple) else { return nil }
        ordered.removeAll { $0 == triple }
        return removed
    }

    @discardableResult
    public mutating func update(with triple: Element) -> Element? {
        insert(triple).inserted ? nil : triple
    }

    public mutating func formUnion(_ other: Graph) {
        for triple in other { insert(triple) }
    }

    public mutating func formIntersection(_ other: Graph) {
        members.formIntersection(other.members)
        ordered.removeAll { !members.contains($0) }
    }

    public mutating func formSymmetricDifference(_ other: Graph) {
        for triple in other where remove(triple) == nil {
            insert(triple)
        }
    }

    // MARK: Matching

    /// The triples that match a pattern; a `nil` component matches anything.
    public func triples(subject: SubjectTerm? = nil, predicate: IRI? = nil, object: ObjectTerm? = nil) -> Graph {
        Graph(filter { triple in
            (subject.map { $0 == triple.subject } ?? true)
                && (predicate.map { $0 == triple.predicate } ?? true)
                && (object.map { $0 == triple.object } ?? true)
        })
    }

    /// The triples, one per line, in N-Triples form.
    public var description: String {
        map(\.description).joined(separator: "\n")
    }
}
