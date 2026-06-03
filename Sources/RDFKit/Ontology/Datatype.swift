import Foundation

/// A declared RDF datatype term.
public protocol RDFDatatype: Term, OntologyContent {}

/// Declares an RDF datatype in the enclosing ontology namespace.
public struct Datatype<Body: DatatypeContent>: NamespaceScopedDeclaration, OntologyContent {
    /// The local datatype name.
    let localName: LocalName

    /// The datatype body content.
    let content: Body

    /// The declaration role.
    let role: OntologyDeclarationRole = .datatype

    /// The declaration body content.
    var bodyContent: any Content { content }

    /// Creates an empty datatype declaration in the enclosing ontology namespace.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates a datatype declaration in the enclosing ontology namespace.
    public init(_ localName: String, @DatatypeContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}

extension Datatype: ClassContent {}
extension Datatype: DatatypeContent {}
