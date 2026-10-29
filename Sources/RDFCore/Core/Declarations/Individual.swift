/// Declares a named individual. The `@Ontology` macro generates a static
/// constant of the ontology for it, the one instance of a final class that
/// conforms to the protocols of its classes: `Individual("nil")` becomes
/// `RDF.nil`.
///
/// The individual it declares is of `OWL.NamedIndividual`, the type RDFKit generates for that
/// term. The declaration form itself has no term identity.
///
///     Individual("nil") {
///         Type(RDF.List)
///     }
public struct Individual: Declaration {
    public let localName: String
    public let content: Content

    public init(_ localName: String, @ContentBuilder _ content: () -> Content) {
        self.localName = localName
        self.content = content()
    }
}
