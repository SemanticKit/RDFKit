import IRIKit

/// States that values of the declared property are instances of `Term`. The `@Ontology` macro types the generated stored property by `Term`.
///
/// `rdfs:range`
///
///     Range(Fauna.Habitat)
public struct Range<Term: Entity>: TermAnnotation {
    public static var metadata: any ContentMetadata {
        RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#range",
            name: "range",
            label: "range",
            comment: "A range of the subject property."
        )
    }

    public init() {}
}
