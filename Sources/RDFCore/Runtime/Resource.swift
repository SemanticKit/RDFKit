/// A resource: an individual, the Swift object that is the thing an RDF
/// description or a DSL declaration describes.
///
/// Every individual is an instance of the Swift class generated for its
/// class, by `@Ontology` from DSL or by `RDFTranslatorPlugin` from RDF, and
/// that class conforms to the protocols of every class the individual is a
/// member of, so `rdf:type` and `rdfs:subClassOf` hold as Swift membership:
///
///     alice is Person   // :alice a foaf:Person
///     alice is Agent    // foaf:Person rdfs:subClassOf foaf:Agent
///
/// Its identity inside the runtime is the object (`alice.knows.contains {
/// $0 === bob }`), and its property values are its stored properties.
public protocol Resource: AnyObject, Sendable, Encodable {
    /// The declaration that names the individual, `alice` in the translated
    /// AliceProfile module: its declared name and vocabulary, from which an
    /// encoder derives the individual's IRI when it leaves the runtime.
    /// `nil` for an individual made in Swift that no declaration names,
    /// which an encoder writes as a blank node.
    var key: TermKey? { get }
}
