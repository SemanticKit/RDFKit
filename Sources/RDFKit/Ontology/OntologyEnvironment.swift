import Foundation

/// Ontology context propagated from a parent ontology to child DSL content.
public struct OntologyEnvironment: Equatable, Hashable, Sendable, Identifiable, IRIRepresentable {
    /// The namespace supplied by the enclosing ontology.
    public let namespace: Namespace

    /// The ontology type name that owns this environment.
    let ownerTypeName: String?

    /// Creates an ontology environment.
    public init(namespace: Namespace, ownerTypeName: String? = nil) {
        self.namespace = namespace
        self.ownerTypeName = ownerTypeName
    }

    /// Creates an ontology environment from ontology DSL content.
    public init<ContentValue: Content>(content: ContentValue, ownerTypeName: String? = nil) {
        self.namespace = ContentNamespaceResolver.namespace(in: content)
        self.ownerTypeName = ownerTypeName
    }

    /// The environment identity.
    public var id: IRI { iri }

    /// The ontology IRI supplied by this environment.
    public var iri: IRI { namespace.iri }
}
