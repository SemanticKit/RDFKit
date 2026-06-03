import Foundation

/// A declared RDF property term.
public protocol RDFProperty: Term, RDFPredicate, OntologyContent {}

/// Declares an RDF property in the enclosing ontology namespace.
public struct Property<Body: PropertyContent>: NamespaceScopedDeclaration, OntologyContent {
    /// The local property name.
    let localName: LocalName

    /// The property body content.
    let content: Body

    /// The declaration role.
    let role: OntologyDeclarationRole = .property

    /// The declaration body content.
    var bodyContent: any Content { content }

    /// Creates an empty property declaration in the enclosing ontology namespace.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates a property declaration in the enclosing ontology namespace.
    public init(_ localName: String, @PropertyContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}

extension Property: ClassContent {}
