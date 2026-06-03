import Foundation

/// Builds content accepted by property declarations.
@resultBuilder
public enum PropertyContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<ContentValue: PropertyContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    public static func buildBlock(_ content: any PropertyContent...) -> ContentGroup {
        ContentGroup(content)
    }

    /// Builds optional property content.
    public static func buildOptional(_ content: (any PropertyContent)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional property content.
    public static func buildEither(first content: any PropertyContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional property content.
    public static func buildEither(second content: any PropertyContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated property content.
    public static func buildArray<ContentValue: PropertyContent>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds property content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: PropertyContent>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
