import Foundation

/// A declared RDF property term.
public protocol RDFProperty: Term, RDFPredicate, Content {}

/// Declares an RDF property in the enclosing ontology namespace.
public struct Property<Body: Content>: NamespaceScopedDeclaration, Content {
    /// The local property name.
    let localName: LocalName

    /// The property body content.
    let content: Body

    /// The declaration body content.
    var bodyContent: any Content { content }

    /// Creates an empty property declaration in the enclosing ontology namespace.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates a property declaration in the enclosing ontology namespace.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
