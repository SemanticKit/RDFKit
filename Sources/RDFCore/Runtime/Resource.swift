import IRIKit

/// A resource: an individual, the Swift object that is the thing an RDF
/// description or a DSL declaration describes.
///
/// RDF 1.2 Concepts §1.2: "Any IRI or literal denotes something in the world
/// (the 'universe of discourse'). These things are called resources." Every
/// individual is an instance of a final class generated for its class, by
/// `@Ontology` from DSL or by `RDFTranslatorPlugin` from RDF, and that class
/// conforms to the protocols of every class the individual is a member of,
/// so `rdf:type` and `rdfs:subClassOf` hold as Swift membership:
///
///     alice is Person   // :alice a foaf:Person
///     alice is Agent    // foaf:Person rdfs:subClassOf foaf:Agent
///
/// An individual is a reference, and its identity inside the runtime is the
/// object: `alice.knows.contains { $0 === bob }`. Its property values are
/// typed Swift values kept in its ``IndividualStorage``. Its `Encodable`
/// conformance writes them, keyed by their properties, and an encoder turns
/// them into triples at the boundary.
public protocol Resource: AnyObject, Description {
    /// The IRI that denotes the individual, or `nil` for a blank node.
    ///
    /// It is read only where the individual leaves the runtime, when an
    /// encoder writes it as a document; inside the runtime the object is
    /// the individual.
    var iri: IRI? { get }
}
