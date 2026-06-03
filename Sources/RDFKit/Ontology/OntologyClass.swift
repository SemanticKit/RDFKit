import Foundation

/// A declared RDF class term.
public protocol RDFClass: Term, OntologyContent {}

/// Declares an RDF class in the enclosing ontology namespace.
public struct Class<Body: ClassContent>: NamespaceScopedDeclaration, OntologyContent {
    /// The local class name.
    let localName: LocalName

    /// The class body content.
    let content: Body

    /// The declaration role.
    let role: OntologyDeclarationRole = .class

    /// The declaration body content.
    var bodyContent: any Content { content }

    /// Creates a class declaration in the enclosing ontology namespace.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
