import Foundation

/// Builds content accepted by datatype declarations.
@resultBuilder
public enum DatatypeContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<ContentValue: DatatypeContent>(_ content: ContentValue) -> ContentValue {
        content
    }

    public static func buildBlock(_ content: any DatatypeContent...) -> ContentGroup {
        ContentGroup(content)
    }

    /// Builds optional datatype content.
    public static func buildOptional(_ content: (any DatatypeContent)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    /// Builds the first branch of conditional datatype content.
    public static func buildEither(first content: any DatatypeContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds the second branch of conditional datatype content.
    public static func buildEither(second content: any DatatypeContent) -> ContentGroup {
        ContentGroup([content])
    }

    /// Builds repeated datatype content.
    public static func buildArray<ContentValue: DatatypeContent>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    /// Builds datatype content guarded by availability checks.
    public static func buildLimitedAvailability<ContentValue: DatatypeContent>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
