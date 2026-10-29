/// An annotation inside a declaration: `Label("Animal")`, `Domain(Fauna.Animal)`.
///
/// The annotations are the properties of RDF, RDFS and OWL that the DSL is
/// written with. `@Ontology` generates each one from its declaration, such as
/// `rdfs:label` from `Property("label")` in RDFS, as an annotation type
/// (`RDFS.label`), and writes `Label("Animal")` in content as
/// `RDFS.label("Animal")`. Annotations that carry text hold the text.
/// Annotations that relate the declared term to another term are
/// ``TermAnnotation``s.
public protocol Annotation: Entity {}
