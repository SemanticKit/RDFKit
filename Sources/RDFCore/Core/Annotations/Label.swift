/// A human-readable name for the declared term.
///
/// `rdfs:label`
///
///     Label("has habitat")
public struct Label: Annotation {
    /// The annotation text.
    public let text: String

    public init(_ text: String) {
        self.text = text
    }
}
