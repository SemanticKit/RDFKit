/// Declares an RDFS class. The `@Ontology` macro generates a protocol for it,
/// whose requirements are the properties with the class as `Domain`, a
/// storing protocol, and a final class whose instances are individuals of
/// the class.
///
/// `rdfs:Class`
///
///     Class("Animal") {
///         Type(RDF.Class)
///         Label("Animal")
///     }
public struct Class: Declaration {
    public let localName: String
    public let content: Entities

    public init(_ localName: String, @ContentBuilder _ content: () -> Entities) {
        self.localName = localName
        self.content = content()
    }
}
