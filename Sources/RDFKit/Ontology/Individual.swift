import Foundation

/// A declared RDF individual term.
public protocol RDFIndividual: Term, Content {}

/// Declares an RDF individual in the enclosing ontology namespace.
public struct Individual<Body: Content>: NamespaceScopedDeclaration, Content {
    /// The local individual name.
    let localName: LocalName

    /// The individual body content.
    let content: Body

    /// The declaration body content.
    var bodyContent: any Content { content }

    /// Creates an empty individual declaration in the enclosing ontology namespace.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates an individual declaration in the enclosing ontology namespace.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
