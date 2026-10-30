/// The term type of a property: `FOAF.knows` for `foaf:knows`, which
/// `RDFTranslatorPlugin` generates from RDF, and `Fauna.hasHabitat`, which
/// `@Ontology` generates from DSL.
///
/// A property is not a value in Swift. It is a requirement on the protocol
/// of each of its domains and a member of the individuals that have it
/// (`alice.knows`), typed by its range, and this term type, which carries its
/// declared key and writes the triples stated about it. Wherever RDF names a
/// property as a value, `owl:inverseOf foaf:made` or `owl:onProperty
/// foaf:knows`, Swift names its term type: `[FOAF.made.self]`. An encoder
/// derives the property's IRI from the key when it leaves the runtime:
///
///     let description = try GraphEncoder().encode(FOAF.knows())
public protocol PropertyTerm: Description {
    /// The declared key of the property.
    static var key: TermKey { get }

    /// The property's description: the triples its declaration states.
    init()
}
