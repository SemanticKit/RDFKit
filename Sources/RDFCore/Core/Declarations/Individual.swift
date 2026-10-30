/// Declares a named individual, `owl:NamedIndividual` (OWL 2 Structural
/// Specification §5.6), a member of the classes its `Type` gives
/// (ClassAssertion, §9.6.1).
///
/// In an `@Ontology` `var body`, the macro generates a Swift class for the
/// individual that conforms to the storing protocol of each of its classes,
/// and an ontology member whose value is that individual. The class carries
/// the individual's declared key; no IRI is stored or declared.
///
///     Individual("tweety") {
///         Type(Fauna.Bird)
///     }
///
///     let tweety = Fauna().tweety
///     tweety is Fauna.Bird   // true
///
/// The W3C vocabularies' own individuals, such as `rdf:nil`, come from
/// translating their published Turtle with `RDFTranslatorPlugin`, never
/// from an `Individual` declaration.
public struct Individual: Declaration {
    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
