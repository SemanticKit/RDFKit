import IRIKit

/// A Swift class whose instances are the members of an RDF class:
/// `FOAF.PersonIndividual` for `foaf:Person`.
///
/// An RDF class is a resource too, an instance of `rdfs:Class` (RDF 1.2
/// Schema §2.2), so the class's own description belongs to the Swift type:
/// its IRI and the triples stated about it, which
/// ``encodeDescription(to:)`` writes. In object position a class is the
/// Swift type itself, never a value standing for it.
///
/// Each conforming class also names `Member`, the Swift type of one member
/// of the class as a property value: `any FOAF.Person` for `foaf:Person`,
/// ``Literal`` for `rdfs:Literal` and its datatypes, ``Value`` for
/// `rdfs:Resource`. `Range(FOAF.Person)` in the DSL is typed through it, so
/// a property's Swift type follows from the class it ranges over.
public protocol ResourceClass: Resource {
    /// The IRI that denotes the class, or `nil` for a blank node.
    static var iri: IRI? { get }

    /// Writes the triples stated about the class, to a keyed container
    /// keyed by ``PropertyKey``.
    static func encodeDescription(to encoder: any Encoder) throws
}
