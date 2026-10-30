/// Turns an ontology's authored `content()` body into content built from the
/// types `@Ontology` generates.
///
/// `@Ontology` attaches it to `func content()`; it is not written by hand.
/// See ``Ontology()``.
@attached(body)
public macro OntologyContent() = #externalMacro(module: "RDFKitMacros", type: "OntologyContentMacro")
