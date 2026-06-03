import Foundation

/// Builds content accepted by annotation blocks.
@resultBuilder
public enum AnnotationContentBuilder {
    /// Builds an empty annotation content block.
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    /// Builds a single annotation content value.
    public static func buildBlock<ContentValue: AnnotationContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    /// Builds a grouped annotation content block.
    public static func buildBlock(_ content: any AnnotationContent...) -> ContentGroup {
        ContentGroup(content)
    }
}
