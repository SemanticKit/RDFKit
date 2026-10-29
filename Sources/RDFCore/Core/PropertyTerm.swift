/// A property, as the type that names it.
///
/// The `@Ontology` macro generates a property term type for every property an
/// ontology declares, such as `Foaf.knows`. The type is the property's
/// identity inside the runtime: an individual keeps the values of a property
/// under the property's term type, so two ontologies that describe the same
/// individual never mix up their values, and no IRI or name stands in for the
/// property.
///
/// Read and write a property's values through its term, with the subject as
/// the subscript argument. The subscript takes the property's `Domain`, so
/// only individuals the property applies to are accepted, and returns its
/// ``PropertyKey/Value``, typed by its `Range`:
///
///     Foaf.knows[alice] = [bob]
///     Cert.key[alice] = [aliceKey]   // cert:key has the domain foaf:Agent
///
/// A property whose domain is a class the same ontology declares is also a
/// member of that class's protocol, `alice.knows`.
public protocol PropertyTerm: Entity, PropertyKey {}
