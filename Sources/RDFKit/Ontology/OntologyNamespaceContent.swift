import Foundation

/// Ontology DSL content that contributes namespace declarations.
protocol OntologyNamespaceContent: Content {
    /// The namespace declarations contributed by this content.
    var declaredNamespaces: [Namespace] { get }
}

extension Content {
    /// The namespace declarations materialized from this content.
    var materializedNamespaces: [Namespace] {
        guard let namespaceContent = self as? any OntologyNamespaceContent else {
            return []
        }

        return namespaceContent.declaredNamespaces
    }

    /// Returns the single namespace declared by this content.
    func materializedNamespace() -> Namespace {
        let namespaces = materializedNamespaces
        precondition(namespaces.count == 1, "Content must declare exactly one namespace.")
        return namespaces[0]
    }

    /// Returns the ontology environment declared by this content.
    func materializedEnvironment(ownerTypeName: String? = nil) -> OntologyEnvironment {
        OntologyEnvironment(namespace: materializedNamespace(), ownerTypeName: ownerTypeName)
    }
}
