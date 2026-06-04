import Foundation

/// A term whose namespace is inferred from an ontology's DSL content.
public protocol OntologyScopedTerm: VocabularyTerm, OntologyContent {
    associatedtype OntologyValue: Ontology

    /// The ontology that supplies this term's namespace.
    static var ontology: OntologyValue { get }
}

public extension OntologyScopedTerm {
    /// The namespace declared by the owning ontology content.
    static var namespace: Namespace {
        ontology.content.materializedNamespace()
    }

    /// The ontology-scoped local name inferred from the generated Swift type name.
    static var localName: LocalName {
        LocalName(String(describing: Self.self))
    }
}
