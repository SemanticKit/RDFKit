import Foundation
import IRIKit

/// A generated ontology term declaration.
///
/// Class-level concerns (static):
///   - `name` — the declared term name
///   - `iri` — the IRI identity
///   - `kind` — class, property, individual, datatype
///
/// Instance-level concerns:
///   - `id` — instance identity (typically the class IRI)
///   - `children` — raw annotation data
///   - domain-specific properties (habitat, diet, etc.)
public protocol OntologyTerm: Sendable, Identifiable, Equatable, Subject, Predicate, Object {

    /// The declared term name (e.g., "Animal", "hasHabitat").
    static var name: String { get }

    /// The IRI for this term type.
    static var iri: IRI { get }

    /// The kind of term (class, property, individual, datatype).
    static var kind: TermKind { get }

    /// Instance identity — the IRI that identifies this specific instance.
    var id: IRI { get }

    /// The raw annotation children from the DSL declaration.
    var children: [any Node] { get }
}

// MARK: - Equatable

extension OntologyTerm {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Convenience

extension OntologyTerm {
    public var isClass: Bool { Self.kind == .class }
    public var isProperty: Bool { Self.kind == .property }
    public var isIndividual: Bool { Self.kind == .individual }
    public var isDatatype: Bool { Self.kind == .datatype }
}
