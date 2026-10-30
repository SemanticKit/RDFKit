/// Declares an RDFS datatype. The `@Ontology` macro generates a value type for it.
///
/// `rdfs:Datatype`
///
///     Datatype("HTML") {
///         SubClassOf(RDF.Literal)
///     }
public struct Datatype: Declaration {
    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
