import Foundation
import IRIKit

/// A generated ontology term declaration.
///
/// Class-level concerns (static):
///   - `name` — the declared term name
///   - `iri` — the IRI identity
///
/// Instance-level concerns:
///   - `id` — instance identity (typically the class IRI)
///   - `children` — raw annotation data
///   - domain-specific properties (habitat, diet, etc.)
///
/// Kind is determined by protocol conformance:
///   - `ClassDeclaration` — class terms
///   - `PropertyDeclaration` — property terms
///   - `IndividualDeclaration` — individual terms
///   - `DatatypeDeclaration` — datatype terms
public protocol OntologyTerm: Sendable, Identifiable, Equatable, Subject, Predicate, Object {

    /// The declared term name (e.g., "Animal", "hasHabitat").
    static var name: String { get }

    /// The IRI for this term type.
    static var iri: IRI { get }

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
