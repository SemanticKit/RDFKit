import Foundation

/// A dependency edge materialized from ontology declaration facts.
public struct OntologyDependencyEdge: Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// The declaration that owns the dependency.
    public let source: IRI

    /// The dependency kind.
    public let kind: OntologyDependencyKind

    /// The dependency target.
    public let target: IRI

    /// Creates an ontology dependency edge.
    public init(source: IRI, kind: OntologyDependencyKind, target: IRI) {
        self.source = source
        self.kind = kind
        self.target = target
    }

    /// A stable textual representation.
    public var description: String { "\(source) --\(kind.rawValue)--> \(target)" }

    public static func < (lhs: OntologyDependencyEdge, rhs: OntologyDependencyEdge) -> Bool {
        if lhs.source != rhs.source { return lhs.source < rhs.source }
        if lhs.kind != rhs.kind { return lhs.kind < rhs.kind }
        return lhs.target < rhs.target
    }
}
