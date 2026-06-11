import Foundation

/// Builds recursive authored RDF content.
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

    public static func buildOptional(_ content: (any Content)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    public static func buildEither(first content: any Content) -> ContentGroup {
        ContentGroup([content])
    }

    public static func buildEither(second content: any Content) -> ContentGroup {
        ContentGroup([content])
    }

    public static func buildArray<ContentValue: Content>(_ components: [ContentValue]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Content })
    }

    public static func buildLimitedAvailability<ContentValue: Content>(_ content: ContentValue) -> ContentGroup {
        ContentGroup([content])
    }
}
