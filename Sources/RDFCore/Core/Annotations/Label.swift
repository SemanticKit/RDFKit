import IRIKit

/// A human-readable name for the declared term.
///
/// `rdfs:label`
///
///     Label("has habitat")
public struct Label: Annotation {
    public static let metadata: any ContentMetadata = RDFMetadata(
        id: "http://www.w3.org/2000/01/rdf-schema#label",
        name: "label",
        label: "label",
        comment: "A human-readable name for the subject."
    )

    /// The annotation text.
    public let text: String

    public init(_ text: String) {
        self.text = text
    }
}
