import IRIKit

/// The namespace of an ontology.
///
/// The `@Ontology` macro reads the namespace from source and computes each
/// generated term's boundary IRI from it at expansion time. At runtime the
/// namespace is a boundary value only.
///
///     Namespace("https://fauna.example.org/ontology#")
public struct Namespace: Entity {
    /// The namespace IRI.
    public let iri: IRI

    public init(_ iri: IRI) {
        self.iri = iri
    }
}
