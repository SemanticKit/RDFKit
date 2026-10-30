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

/// Gives the storing protocol `@Ontology` generates for a class,
/// `Fauna.AnimalStoring`, the accessors of the class's own properties,
/// backed by the class's values in the individual's
/// ``RDFCore/IndividualStorage`` of ``RDFCore/IndividualValues``.
///
/// An individual declared in another ontology or module that is typed with
/// the class, `Type(Fauna.Animal)`, conforms to the storing protocol, so it
/// stores the values of the class and its superclasses, each property once.
/// `@Ontology` attaches it; it is not written by hand.
@attached(extension, names: arbitrary)
public macro IndividualStoring() = #externalMacro(module: "RDFKitMacros", type: "IndividualStoringMacro")
