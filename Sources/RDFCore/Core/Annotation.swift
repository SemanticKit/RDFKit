/// An annotation inside a declaration that carries text: `Label("Animal")`,
/// `Comment("An animal.")`.
///
/// An annotation that relates the declared term to another term,
/// `Domain(Fauna.Animal)`, is not a value: `@Ontology` writes it as the Swift
/// declaration it describes, protocol refinement or a requirement and its
/// type.
public protocol Annotation: Entity {}
