/// An annotation that relates the declared term to another term.
///
/// Inside an `@Ontology` `content()` it is written with the related type as
/// its argument, `Domain(Fauna.Animal)`, and the relation is the annotation
/// type for that term, `RDFS.domain<Fauna.Animal>`, never an IRI or a string.
/// The related term is ``Term``: a class protocol (`Fauna.Animal`), a datatype
/// value type or a property term type.
public protocol TermAnnotation: Annotation {
    /// The related term.
    associatedtype Term

    init()
}
