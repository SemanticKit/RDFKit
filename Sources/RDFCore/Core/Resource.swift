/// An individual: a member of one or more classes.
///
/// The `@Ontology` macro generates a protocol for every class an ontology
/// declares, and every class protocol refines `Resource` (directly, or through
/// the classes it is a subclass of). An individual is an instance of a final
/// class that conforms to its classes' protocols.
///
/// An individual is a reference. Its identity inside the runtime is the object
/// itself: the zebra a lion preys on is the same object as the zebra a
/// habitat is inhabited by, so `lion.preysOn.first === savanna.inhabitedBy.last`.
/// No IRI or name stands in for it. Individuals are created in an
/// ``IndividualGraph``, which owns their lifetime. The static ``Entity/metadata`` of an
/// individual's type is the boundary projection of the term that type was
/// generated from, read only when the individual leaves the runtime.
///
/// `rdfs:Resource`
public protocol Resource: AnyObject, Entity {}
