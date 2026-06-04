import Foundation

/// Resolves the single namespace declaration carried by DSL content.
enum ContentNamespaceResolver {
    /// Returns the namespace declared by content.
    static func namespace<ContentValue: Content>(in content: ContentValue) -> Namespace {
        let namespaces = namespaces(in: content)
        precondition(namespaces.count == 1, "Content must declare exactly one namespace.")
        return namespaces[0]
    }

    /// Returns the ontology environment declared by content.
    static func environment<ContentValue: Content>(
        in content: ContentValue,
        ownerTypeName: String? = nil
    ) -> OntologyEnvironment {
        OntologyEnvironment(namespace: namespace(in: content), ownerTypeName: ownerTypeName)
    }

    /// Returns all namespaces declared by content.
    private static func namespaces(in content: any Content) -> [Namespace] {
        guard let namespaceContent = content as? any OntologyNamespaceContent else {
            return []
        }

        return namespaceContent.declaredNamespaces
    }
}
