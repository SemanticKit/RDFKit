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
}
