/// Declares an RDFS class. The `@Ontology` macro generates a protocol for it,
/// whose requirements are the properties with the class as `Domain`, and a
/// final class whose instances are individuals of the class.
///
/// The class it declares is of `RDFS.Class`, the type RDFKit generates for that
/// term. The declaration form itself has no term identity.
///
///     Class("Animal") {
///         Type(RDFS.Class)
///         Label("Animal")
///     }
public struct Class: Declaration {
    public let localName: String
    public let content: Content

    public init(_ localName: String, @ContentBuilder _ content: () -> Content) {
        self.localName = localName
        self.content = content()
    }
}
