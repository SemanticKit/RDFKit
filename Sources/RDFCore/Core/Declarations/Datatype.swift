/// Declares an RDFS datatype. The `@Ontology` macro generates a value type for it.
///
/// The datatype it declares is of `RDFS.Datatype`, the type RDFKit generates for that
/// term. The declaration form itself has no term identity.
///
///     Datatype("HTML") {
///         SubClassOf(RDFS.Literal)
///     }
public struct Datatype: Declaration {
    public let localName: String
    public let content: Content

    public init(_ localName: String, @ContentBuilder _ content: () -> Content) {
        self.localName = localName
        self.content = content()
    }
}
