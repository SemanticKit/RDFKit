/// A statement of an ontology's DSL content: a declaration form (``Class``,
/// ``Property``, ``Datatype``), an annotation, a ``Namespace`` or a
/// ``Prefix``.
///
/// The forms are syntax that `@Ontology` reads and writes as the Swift they
/// describe. They carry no RDF of their own: what `rdfs:Class` or
/// `rdfs:label` is comes from the one translation of rdf.ttl, rdfs.ttl and
/// owl.ttl, whose types the generated code names (`RDF.ClassIndividual`,
/// `RDF.label`).
public protocol Entity: Node {}
