/// The declarer of a vocabulary's terms: an `@Ontology` type, or a namespace
/// a translated module's documents name.
///
/// It is the coding information a ``TermKey`` refers to, as a `CodingKeys`
/// type is for a `Codable` type's properties: its ``namespace`` is read only
/// where a term leaves the runtime, and an encoder derives the term's IRI from
/// it and the term's declared name (RDF 1.2 Concepts §1.4, "IRIs ... are often
/// abbreviated" by a namespace and a local name).
public protocol Vocabulary: Sendable {
    /// The namespace the vocabulary's terms are declared in, as declared:
    /// `Namespace("https://fauna.example.org/ontology#")`.
    static var namespace: String { get }
}
