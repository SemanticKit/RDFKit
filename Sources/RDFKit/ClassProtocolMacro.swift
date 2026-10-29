/// Implements a class protocol's properties on the stored values of its
/// individuals.
///
/// `@Ontology` attaches it to every class protocol it generates; it is not
/// written by hand. See ``Ontology()``.
@attached(extension, names: arbitrary)
public macro ClassProtocol() = #externalMacro(module: "RDFKitMacros", type: "ClassProtocolMacro")
