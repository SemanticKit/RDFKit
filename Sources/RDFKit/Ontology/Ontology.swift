import Foundation

/// A protocol-first ontology definition.
public protocol Ontology: Identifiable, IRIRepresentable where ID == IRI {
    associatedtype Body: Content

    /// The ontology content.
    @ContentBuilder var content: Body { get }
}

extension Ontology {
    /// The ontology environment supplied to child content.
    public var environment: OntologyEnvironment {
        content.materializedEnvironment(ownerTypeName: String(describing: Self.self))
    }

    /// The ontology identity.
    public var id: IRI { environment.iri }

    /// The ontology IRI.
    public var iri: IRI { id }
}
