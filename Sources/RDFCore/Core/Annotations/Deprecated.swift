/// Marks the declared term as deprecated, with the reason when there is one.
/// `@Ontology` writes it as `@available(*, deprecated)` on the term's Swift
/// declarations, the reason as its message.
///
/// `owl:deprecated`
///
///     Deprecated()
///     Deprecated("Use Baz.")
public struct Deprecated: Annotation {
    /// Why the term is deprecated, if stated.
    public let reason: String?

    public init(_ reason: String? = nil) {
        self.reason = reason
    }
}
