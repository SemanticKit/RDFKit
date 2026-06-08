import Foundation

/// Authored RDF content.
public protocol Content: Sendable {}

/// Content whose term identity is scoped by the enclosing ontology namespace.
protocol NamespaceScopedDeclaration: Content {
    /// The local name declared inside the enclosing ontology namespace.
    var localName: LocalName { get }

    /// The declaration body content.
    var bodyContent: any Content { get }
}

extension NamespaceScopedDeclaration {
    /// Returns the declaration IRI inside an ontology environment.
    func iri(in environment: OntologyEnvironment) -> IRI {
        QualifiedName(namespace: environment.namespace, localName: localName).iri
    }

}

/// Empty authored RDF content.
public struct EmptyContent: Content {
    /// Creates empty content.
    public init() {}
}

/// A group of authored RDF content values.
public struct ContentGroup: Content {
    /// The grouped content values.
    public let elements: [any Content]

    /// Creates a content group.
    public init(_ elements: [any Content]) {
        self.elements = elements
    }
}

extension ContentGroup: OntologyNamespaceContent {
    /// The namespace declarations contributed by grouped content.
    var declaredNamespaces: [Namespace] {
        var namespaces: [Namespace] = []

        for element in elements {
            if let namespaceContent = element as? any OntologyNamespaceContent {
                namespaces.append(contentsOf: namespaceContent.declaredNamespaces)
            }
        }

        return namespaces
    }
}

/// Builds recursive authored RDF content.
@resultBuilder
public enum ContentBuilder {
    /// Builds an empty content block.
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    /// Builds one content value without wrapping it.
    public static func buildBlock<ContentValue: Content>(_ content: ContentValue) -> ContentValue {
        content
    }

    /// Builds a group of content values.
    public static func buildBlock(_ content: any Content...) -> ContentGroup {
        ContentGroup(content)
    }

    /// Builds optional content.
    public static func buildOptional(_ content: (any Content)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional content.
    public static func buildEither(first content: any Content) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional content.
    public static func buildEither(second content: any Content) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated content.
    public static func buildArray<ContentValue: Content>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: Content>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
