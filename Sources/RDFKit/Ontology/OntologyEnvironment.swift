import Foundation

/// Ontology context propagated from a parent ontology to child DSL content.
public struct OntologyEnvironment: Equatable, Hashable, Sendable, Identifiable, IRIRepresentable {
    /// The namespace supplied by the enclosing ontology.
    public let namespace: Namespace

    /// Creates an ontology environment.
    public init(namespace: Namespace) {
        self.namespace = namespace
    }

    /// Creates an ontology environment from ontology DSL content.
    public init<ContentValue: Content>(content: ContentValue) {
        self.namespace = ContentNamespaceResolver.namespace(in: content)
    }

    /// The environment identity.
    public var id: IRI { iri }

    /// The ontology IRI supplied by this environment.
    public var iri: IRI { namespace.iri }
}
