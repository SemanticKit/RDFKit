/// Implements a class protocol's properties on the property sets of its
/// individuals, and an ontology's properties for other ontologies' classes
/// on its extension point.
///
/// `@Ontology` attaches it to every class protocol it generates; it is not
/// written by hand. See ``Ontology()``.
@attached(extension, names: arbitrary)
public macro ClassProtocol() = #externalMacro(module: "RDFKitMacros", type: "ClassProtocolMacro")
