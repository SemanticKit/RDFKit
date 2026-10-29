import IRIKit

/// States that the declared class is a subclass of `Term`. Generated types inherit the properties of their superclasses in the same ontology.
///
/// `rdfs:subClassOf`
///
///     SubClassOf(RDFS.Resource)
public struct SubClassOf<Term: Entity>: TermAnnotation {
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
