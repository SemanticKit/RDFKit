import IRIKit
import RDFCore

/// An individual an RDF document describes, as the Swift object the
/// `RDFTranslatorPlugin` built it into.
///
/// RDF 1.2 Concepts §1.2: "Any IRI or literal denotes something in the world
/// (the 'universe of discourse'). These things are called resources." An
/// individual is an instance of the Swift class generated for the class the
/// document states it is a member of, and that class conforms to the
/// protocols of every class it is a member of, stated or entailed, so
/// `rdf:type` and `rdfs:subClassOf` hold as Swift membership:
///
///     alice is Person   // :alice a foaf:Person
///     alice is Agent    // foaf:Person rdfs:subClassOf foaf:Agent
///
/// Its properties are stored properties of its class, typed by their range:
/// `alice.knows` is `[any FOAF.Person]`. Its `Encodable` conformance writes
/// those members, keyed by their properties.
public protocol Resource: AnyObject, Sendable, Description {
    /// The IRI that denotes the individual, or `nil` for a blank node.
    ///
    /// It is read only where the individual leaves the runtime, when an
    /// encoder writes it as a document.
    var iri: IRI? { get }
}
