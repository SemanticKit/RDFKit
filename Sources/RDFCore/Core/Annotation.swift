/// An annotation inside a declaration that carries text: `Label("Animal")`,
/// `Comment("...")`, `SeeAlso("...")`, `Deprecated()`.
///
/// Annotations that relate the declared term to another term,
/// `SubClassOf(Fauna.Animal)` or `Domain(Fauna.Animal)`, are not values.
/// `@Ontology` reads them as syntax and writes them as the Swift
/// declarations they describe: protocol refinement, the requirements of a
/// class protocol and their types, and the `Domain` and `Range` type
/// aliases of a property term type.
public protocol Annotation: Entity {}
