/// A description of the declared term. The `@Ontology` macro turns it into the DocC summary of the generated type.
///
/// `rdfs:comment`
///
///     Comment("The class of all animals.")
public struct Comment: Annotation {
    /// The annotation text.
    public let text: String

    public init(_ text: String) {
        self.text = text
    }
}
