/// Declares an RDF property. The `@Ontology` macro generates a term type for
/// it and a requirement on the protocol of its `Domain`, the property's
/// values typed by the members of its `Range`.
///
/// `rdf:Property`
///
///     Property("hasHabitat") {
///         Domain(Fauna.Animal)
///         Range(Fauna.Habitat)
///     }
public struct Property: Declaration {
    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
