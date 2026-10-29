import IRIKit

/// The namespace of an ontology.
///
/// The `@Ontology` macro reads the namespace from source and computes each
/// generated term's boundary IRI from it at expansion time. At runtime the
/// namespace is a boundary value only.
///
///     Namespace("https://fauna.example.org/ontology#")
public struct Namespace: Entity {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://semantickit.io/o/2026/06/rdfkit#Namespace",
        name: "Namespace",
        label: "Namespace",
        comment: "The namespace of the Ontology."
    )

    /// The namespace IRI.
    public let iri: IRI

    public init(_ iri: IRI) {
        self.iri = iri
    }
}
