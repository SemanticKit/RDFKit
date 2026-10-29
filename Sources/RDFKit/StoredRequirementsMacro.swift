/// Implements a class protocol's requirements for
/// ``RDFCore/StoredIndividual``, so every individual type of the class, or of
/// a subclass in any ontology, has them.
///
/// `@Ontology` attaches it to every class protocol it generates; it is not
/// written by hand. See ``Ontology()``.
@attached(extension, names: arbitrary)
public macro StoredRequirements() = #externalMacro(module: "RDFKitMacros", type: "StoredRequirementsMacro")
