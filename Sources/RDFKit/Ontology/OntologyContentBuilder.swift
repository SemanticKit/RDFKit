import Foundation

/// Builds content accepted by ontology roots.
@resultBuilder
public enum OntologyContentBuilder {
    /// Builds an empty ontology content block.
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    /// Builds a single ontology content value.
    public static func buildBlock<ContentValue: OntologyContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    /// Builds a grouped ontology content block.
    public static func buildBlock(_ content: any OntologyContent...) -> ContentGroup {
        ContentGroup(content)
    }

    /// Builds optional ontology content.
    public static func buildOptional(_ content: (any OntologyContent)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional ontology content.
    public static func buildEither(first content: any OntologyContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional ontology content.
    public static func buildEither(second content: any OntologyContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated ontology content.
    public static func buildArray<ContentValue: OntologyContent>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds ontology content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: OntologyContent>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
