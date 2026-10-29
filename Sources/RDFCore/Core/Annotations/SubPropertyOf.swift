import IRIKit

/// States that the declared property is a subproperty of `Term`.
///
/// `rdfs:subPropertyOf`
///
///     SubPropertyOf(RDFS.seeAlso)
public struct SubPropertyOf<Term: Entity>: TermAnnotation {
    public static var metadata: any ContentMetadata {
        RDFMetadata(
            id: "http://www.w3.org/2000/01/rdf-schema#subPropertyOf",
            name: "subPropertyOf",
            label: "subPropertyOf",
            comment: "The subject is a subproperty of a property."
        )
    }

    public init() {}
}
