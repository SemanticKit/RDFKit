import IRIKit

/// States that the declared property applies to instances of `Term`. The `@Ontology` macro puts the property on the type generated for `Term`.
///
/// `rdfs:domain`
///
///     Domain(Fauna.Animal)
public struct Domain<Term: Entity>: TermAnnotation {
    public static var metadata: any ContentMetadata {
        RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#domain",
            name: "domain",
            label: "domain",
            comment: "A domain of the subject property."
        )
    }

    public init() {}
}
