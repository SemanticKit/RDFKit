/// The values one individual has for one property, as typed Swift values.
///
/// The `@Ontology` macro and `RDFTranslatorPlugin` generate one for every
/// property a class can have: `FOAF.knowsValue` holds `[any FOAF.Person]`.
/// It starts empty, and writes its values keyed by its property, so an
/// individual's ``IndividualStorage`` encodes whatever properties it has.
public protocol PropertyValue: Sendable, Encodable {
    /// No value stated.
    init()
}
