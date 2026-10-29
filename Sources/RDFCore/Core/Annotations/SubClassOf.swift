import IRIKit

/// States that the declared class is a subclass of `Term`. The `@Ontology` macro makes the class protocol refine the protocol of `Term`.
///
/// `rdfs:subClassOf`
///
///     SubClassOf(RDFS.Resource)
public struct SubClassOf<Term>: TermAnnotation {
    public static var metadata: any ContentMetadata {
        RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#subClassOf",
            name: "subClassOf",
            label: "subClassOf",
            comment: "The subject is a subclass of a class."
        )
    }

    public init() {}
}
