import Foundation

/// Builds content accepted by class declarations.
@resultBuilder
public enum ClassContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<ContentValue: ClassContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    public static func buildBlock(_ content: any ClassContent...) -> ContentGroup {
        ContentGroup(content)
    }

    /// Builds optional class content.
    public static func buildOptional(_ content: (any ClassContent)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional class content.
    public static func buildEither(first content: any ClassContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional class content.
    public static func buildEither(second content: any ClassContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated class content.
    public static func buildArray<ContentValue: ClassContent>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds class content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: ClassContent>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
