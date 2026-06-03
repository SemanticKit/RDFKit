import Foundation

/// Builds content accepted by individual declarations.
@resultBuilder
public enum IndividualContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<ContentValue: IndividualContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    public static func buildBlock(_ content: any IndividualContent...) -> ContentGroup {
        ContentGroup(content)
    }

    /// Builds optional individual content.
    public static func buildOptional(_ content: (any IndividualContent)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional individual content.
    public static func buildEither(first content: any IndividualContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional individual content.
    public static func buildEither(second content: any IndividualContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated individual content.
    public static func buildArray<ContentValue: IndividualContent>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds individual content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: IndividualContent>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
