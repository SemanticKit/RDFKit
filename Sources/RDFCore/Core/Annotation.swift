/// An annotation inside a declaration: `Label("Animal")`, `Domain(Fauna.Animal)`.
///
/// Annotations that carry text (``Label``, ``Comment``) hold the text.
/// Annotations that relate the declared term to another term are
/// ``TermAnnotation``s.
public protocol Annotation: Entity {}
