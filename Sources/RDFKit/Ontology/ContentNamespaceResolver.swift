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
    static func environment<ContentValue: Content>(in content: ContentValue) -> OntologyEnvironment {
        OntologyEnvironment(namespace: namespace(in: content))
    }

    /// Returns all namespaces declared by content.
    private static func namespaces(in content: any Content) -> [Namespace] {
        if let namespace = content as? Namespace {
            return [namespace]
        }
        if let group = content as? ContentGroup {
            return group.elements.flatMap(namespaces(in:))
        }
        return []
    }
}
