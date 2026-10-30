/// The values one individual has for one property, as typed Swift values.
///
/// The `@Ontology` macro and `RDFTranslatorPlugin` generate one for every
/// property a class can have: `FOAF.knowsValue` holds `[any FOAF.Person]`.
/// It starts empty, and writes its values keyed by its property, so an
/// individual's ``IndividualStorage`` encodes whatever properties it has. A
/// translated one is `Decodable` too: it reads its values from the decoder
/// an RDF format decoder gives it, keyed the same way.
public protocol PropertyValue: Sendable, Encodable {
    /// The declared key of the property, from which a coder derives its IRI.
    static var key: TermKey { get }

    /// No value stated.
    init()
}
