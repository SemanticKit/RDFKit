import Foundation

/// A protocol-first ontology definition.
public protocol Ontology: Identifiable, IRIRepresentable where ID == IRI {
    associatedtype Aliases: AliasContent
    associatedtype Body: OntologyContent

    /// The ontology namespace.
    var namespace: Namespace { get }

    /// Prefix and namespace aliases used by the ontology.
    @AliasBuilder var aliases: Aliases { get }

    /// The ontology declarations and annotations.
    @ContentBuilder var content: Body { get }
}

extension Ontology {
    /// The ontology identity.
    public var id: IRI { namespace.iri }

    /// The ontology IRI.
    public var iri: IRI { id }
}
