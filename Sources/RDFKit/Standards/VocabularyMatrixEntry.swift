import Foundation

/// The role a standards matrix row plays in a vocabulary.
public enum VocabularyRole: String, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// A class term.
    case `class`

    /// A property term.
    case property

    /// A datatype term.
    case datatype

    /// An individual term.
    case individual

    /// A term whose role is not more specific in the source graph.
    case term

    /// A stable textual representation.
    public var description: String { rawValue }

    public static func < (lhs: VocabularyRole, rhs: VocabularyRole) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// A dependency edge captured from a standards vocabulary graph.
public struct VocabularyDependencyEdge: Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// The dependency predicate kind.
    public let kind: String

    /// The target resource IRI.
    public let target: IRI

    /// Creates a dependency edge.
    public init(kind: String, target: IRI) {
        self.kind = kind
        self.target = target
    }

    /// A stable textual representation.
    public var description: String { "\(kind) -> \(target)" }

    public static func < (lhs: VocabularyDependencyEdge, rhs: VocabularyDependencyEdge) -> Bool {
        if lhs.kind != rhs.kind { return lhs.kind < rhs.kind }
        return lhs.target < rhs.target
    }
}

/// One row in the RDF/RDFS/OWL standards matrix.
public struct VocabularyMatrixEntry: Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// The vocabulary namespace label.
    public let namespace: String

    /// The term local name.
    public let localName: LocalName

    /// The term IRI.
    public let iri: IRI

    /// The derived vocabulary role.
    public let role: VocabularyRole

    /// Direct rdf:type values.
    public let directTypes: [IRI]

    /// Transitive rdfs:subClassOf chain values.
    public let subclassChain: [IRI]

    /// Transitive rdfs:subPropertyOf chain values.
    public let subpropertyChain: [IRI]

    /// Direct rdfs:domain values.
    public let domain: [IRI]

    /// Direct rdfs:range values.
    public let range: [IRI]

    /// Direct rdfs:label values.
    public let labels: [String]

    /// Direct rdfs:comment values.
    public let comments: [String]

    /// Direct rdfs:seeAlso values.
    public let seeAlso: [IRI]

    /// Direct rdfs:isDefinedBy values.
    public let isDefinedBy: [IRI]

    /// Dependency edges derived from the row.
    public let dependencyEdges: [VocabularyDependencyEdge]

    /// Swift protocols required for this term.
    public let requiredSwiftProtocols: [String]

    /// A stable textual representation.
    public var description: String { "\(namespace):\(localName)" }

    public static func < (lhs: VocabularyMatrixEntry, rhs: VocabularyMatrixEntry) -> Bool {
        lhs.iri < rhs.iri
    }
}
