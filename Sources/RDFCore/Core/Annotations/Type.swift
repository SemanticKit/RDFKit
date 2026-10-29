import IRIKit

/// States that the declared term is an instance of `Term`.
///
/// `rdf:type`
///
///     Type(RDFS.Class)
public struct Type<Term>: TermAnnotation {
    public static var metadata: any ContentMetadata {
        RDFMetadata(
            id: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            name: "type",
            label: "type",
            comment: "The subject is an instance of a class."
        )
    }

    public init() {}
}
