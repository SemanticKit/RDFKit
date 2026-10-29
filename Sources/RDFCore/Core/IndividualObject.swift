/// An object that is an individual: a member of one or more classes.
///
/// The `@Ontology` macro generates a protocol for every class an ontology
/// declares. Every class protocol refines `RDFS.Resource`, which RDFS.swift
/// declares and which refines `IndividualObject`. An individual is an
/// instance of a final class that conforms to its classes' protocols.
///
/// An individual is a reference. Its identity inside the runtime is the
/// object itself: the zebra a lion preys on is the same object as the zebra
/// a habitat is inhabited by, so `lion.preysOn.first === savanna.inhabitedBy.last`.
/// No IRI or name stands in for it. The static ``Entity/metadata`` of an
/// individual's type is the boundary projection of the term that type was
/// generated from, read only when the individual leaves the runtime.
///
/// An individual keeps the values of its properties in its
/// ``individualProperties``, one ``PropertySet`` for each class whose
/// properties it has. Individuals are created in an ``IndividualGraph``,
/// which owns their lifetime.
public protocol IndividualObject: AnyObject, Entity {
    /// The values of this individual's properties.
    var individualProperties: IndividualProperties { get }
}
