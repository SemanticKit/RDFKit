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
    /// The declared key of the named individual this Swift class is the class
    /// of, or `nil` for an individual no declaration names, which an encoder
    /// writes as a blank node.
    ///
    /// A named individual (`Individual("tweety")` in the DSL, `:alice` in
    /// translated RDF) gets a Swift class of its own that carries its key as
    /// type-level coding information, as a `Codable` type carries its
    /// `CodingKeys`. The instance holds no IRI.
    static var key: TermKey? { get }
}

extension Resource {
    /// No declaration names an individual made in Swift: it is a blank node.
    public static var key: TermKey? { nil }
}
