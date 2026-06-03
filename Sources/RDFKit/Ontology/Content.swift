import Foundation

/// General ontology DSL content.
public protocol Content: Sendable {}

/// Top-level ontology content.
public protocol OntologyContent: Content {}

/// Content accepted by class declarations.
public protocol ClassContent: Content {}

/// Content accepted by property declarations.
public protocol PropertyContent: Content {}

/// Content accepted by datatype declarations.
public protocol DatatypeContent: Content {}

/// Content accepted by individual declarations.
public protocol IndividualContent: Content {}

/// Content accepted by annotation declarations.
public protocol AnnotationContent: Content {}

/// Empty DSL content.
public struct EmptyContent: OntologyContent, ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// Creates empty content.
    public init() {}
}

/// A group of DSL content values.
public struct ContentGroup: OntologyContent, ClassContent, PropertyContent, DatatypeContent, IndividualContent, AnnotationContent {
    /// The grouped content values.
    public let elements: [any Content]

    /// Creates a content group.
    public init(_ elements: [any Content]) {
        self.elements = elements
    }
}

/// Builds protocol-based ontology content.
@resultBuilder
public enum ContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<ContentValue: Content>(_ content: ContentValue) -> ContentValue {
        content
    }

    public static func buildBlock(_ content: any Content...) -> ContentGroup {
        ContentGroup(content)
    }
}
