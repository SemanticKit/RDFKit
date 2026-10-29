/// A statement of an ontology's `content()`: a declaration form
/// (``Class``, ``Property``, ``Datatype``, ``Individual``), an annotation,
/// a ``Namespace`` or a ``Prefix``.
///
/// A content element carries no term identity of its own. The terms it
/// declares are the types `@Ontology` generates, each an ``Entity`` whose
/// boundary IRI is projected from the ontology's namespace. `Class("Animal")`
/// is the statement that declares `Fauna.Animal`; it is not `rdfs:Class`,
/// which is the generated `RDFS.Class`.
public protocol ContentElement: Sendable {}
