/// An annotation inside a declaration: `Label("Animal")`, `Domain<Fauna.Animal>()`.
///
/// Annotations that relate a term to another term take that term as a generic
/// argument, so the relation is a Swift type, never an IRI or a string.
/// Annotations that carry text (``Label``, ``Comment``) hold the text.
public protocol Annotation: Entity {}

/// An annotation that relates the declared term to another term.
///
/// The related term is the ``Term`` type itself.
public protocol TermAnnotation: Annotation {
    /// The related term.
    associatedtype Term: Entity

    init()
}
