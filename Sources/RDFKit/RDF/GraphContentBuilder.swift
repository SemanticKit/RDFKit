import Foundation

/// Builds RDF graph content from protocol-conforming values.
@resultBuilder
public enum GraphContentBuilder {
    /// Builds empty graph content.
    public static func buildBlock() -> GraphContentGroup {
        GraphContentGroup([])
    }

    /// Builds one graph content value without wrapping it.
    public static func buildBlock<ContentValue: GraphContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    /// Builds a group of graph content values.
    public static func buildBlock(_ content: any GraphContent...) -> GraphContentGroup {
        GraphContentGroup(content)
    }
}
