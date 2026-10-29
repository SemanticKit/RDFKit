/// Declares an RDF property. The `@Ontology` macro generates a term type for
/// it and a requirement on the protocol of its `Domain`, typed by its `Range`:
/// many values by default, at most one when the property is typed
/// `OWL.FunctionalProperty`.
///
/// The property it declares is of `RDF.Property`, the type RDFKit generates for that
/// term. The declaration form itself has no term identity.
///
///     Property("hasHabitat") {
///         Domain(Fauna.Animal)
///         Range(Fauna.Habitat)
///     }
public struct Property: Declaration {
    public let localName: String
    public let content: Content

    public init(_ localName: String, @ContentBuilder _ content: () -> Content) {
        self.localName = localName
        self.content = content()
    }
}
