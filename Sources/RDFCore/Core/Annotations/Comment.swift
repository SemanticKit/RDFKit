import IRIKit

/// A description of the declared term. The `@Ontology` macro turns it into the DocC summary of the generated type.
///
/// `rdfs:comment`
///
///     Comment("The class of all animals.")
public struct Comment: Annotation {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#comment",
        name: "comment",
        label: "comment",
        comment: "A description of the subject resource."
    )

    /// The annotation text.
    public let text: String

    public init(_ text: String) {
        self.text = text
    }
}
