import IRIKit

/// The boundary projection of an ``Entity``.
///
/// Metadata is read when a term leaves the runtime: its IRI for Turtle,
/// N-Triples, SPARQL or SHACL, and its label and comment for documentation.
/// It never carries relations to other terms. Those are Swift declarations:
/// protocol refinement for `SubClassOf`, a class protocol's requirements and
/// their types for `Domain` and `Range`, and a property term type's `Domain`
/// and `Range` type aliases.
public protocol ContentMetadata: Codable, Identifiable, Sendable {
    /// The IRI of the term, for use at the boundary only.
    var id: IRI { get }

    /// The local name the term was declared with.
    var name: String { get }

    /// The `rdfs:label` of the term, if declared.
    var label: String? { get }

    /// The `rdfs:comment` of the term, if declared.
    var comment: String? { get }
}
