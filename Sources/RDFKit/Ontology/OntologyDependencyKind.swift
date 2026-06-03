import Foundation

/// The kind of dependency edge materialized from ontology declaration facts.
public enum OntologyDependencyKind: String, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// An rdf:type dependency.
    case type

    /// An rdfs:subClassOf dependency.
    case subClassOf

    /// An rdfs:subPropertyOf dependency.
    case subPropertyOf

    /// An rdfs:domain dependency.
    case domain

    /// An rdfs:range dependency.
    case range

    /// An rdfs:seeAlso dependency.
    case seeAlso

    /// An rdfs:isDefinedBy dependency.
    case isDefinedBy

    /// A stable textual representation.
    public var description: String { rawValue }

    public static func < (lhs: OntologyDependencyKind, rhs: OntologyDependencyKind) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
