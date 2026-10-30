import IRIKit

/// A Swift class that is an RDF class: its instances are the class's
/// members.
///
/// An RDF class is a resource too, an instance of `rdfs:Class` (RDF 1.2
/// Schema §2.2), so the class's own description belongs to the Swift type:
/// its IRI and the triples its document states about it, which
/// ``encodeDescription(to:)`` writes. In object position a class is the
/// Swift type itself, `FOAF.PersonIndividual.self`, never a value standing
/// for it.
public protocol Class: Resource {
    /// The IRI that denotes the class, or `nil` for a blank node.
    static var iri: IRI? { get }

    /// Writes the triples the class's document states about the class, to
    /// a keyed container keyed by ``PropertyKey``.
    static func encodeDescription(to encoder: any Encoder) throws
}
