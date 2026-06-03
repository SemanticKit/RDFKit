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

    /// Builds optional annotation content.
    public static func buildOptional(_ content: (any AnnotationContent)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional annotation content.
    public static func buildEither(first content: any AnnotationContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional annotation content.
    public static func buildEither(second content: any AnnotationContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated annotation content.
    public static func buildArray<ContentValue: AnnotationContent>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds annotation content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: AnnotationContent>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
