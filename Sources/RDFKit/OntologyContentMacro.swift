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

/// Gives the storing protocol `@Ontology` generates for a property,
/// `Fauna.hasHabitatStoring`, the property's accessors, backed by the
/// property's value in the individual's ``RDFCore/IndividualStorage``.
///
/// The storing protocol of each domain of the property refines it, and an
/// individual declared in another ontology or module that is typed with a
/// domain, `Type(Fauna.Animal)`, conforms to the domain's storing protocol,
/// so the property is supplied once. `@Ontology` attaches it; it is not
/// written by hand.
@attached(extension, names: arbitrary)
public macro IndividualStoring() = #externalMacro(module: "RDFKitMacros", type: "IndividualStoringMacro")
