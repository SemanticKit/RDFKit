/// Gives each property requirement of a class protocol a default
/// implementation that keeps the values in the individual's
/// `RDFCore.IndividualStorage`, so an individual type of any ontology can
/// conform to the class.
///
/// `@Ontology` attaches it to every class protocol it generates; it is not
/// written by hand. See ``Ontology()``.
@attached(extension, names: arbitrary)
public macro ClassProperties() = #externalMacro(module: "RDFKitMacros", type: "ClassPropertiesMacro")
