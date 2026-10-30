/// Turns an ontology's authored `var body` into content built from the
/// types `@Ontology` generates.
///
/// `@Ontology` attaches it to `var body`; it is not written by hand.
/// `file` and `line` are where the authored body opens. The getter a body
/// macro on a computed property is given is built outside the authored
/// file, so `@Ontology` passes them for the content's `#sourceLocation`
/// lines. See ``Ontology()``.
@attached(body)
public macro OntologyContent(file: String = "", line: Int = 0) = #externalMacro(module: "RDFKitMacros", type: "OntologyContentMacro")
