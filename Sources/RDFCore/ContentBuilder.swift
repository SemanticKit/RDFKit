import Foundation

/// Builds recursive authored RDF content.
@resultBuilder
public enum ContentBuilder {
    public static func buildBlock() -> EmptyContent {
        EmptyContent()
    }

    public static func buildBlock<Content: Node>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock(_ content: any Node...) -> ContentGroup {
        ContentGroup(content)
    }

    public static func buildOptional(_ content: (any Node)?) -> ContentGroup {
        content.map { ContentGroup([$0]) } ?? ContentGroup([])
    }

    public static func buildEither(first content: any Node) -> ContentGroup {
        ContentGroup([content])
    }

    public static func buildEither(second content: any Node) -> ContentGroup {
        ContentGroup([content])
    }

    public static func buildArray<Content: Node>(_ components: [Content]) -> ContentGroup {
        ContentGroup(components.map { $0 as any Node })
    }

    public static func buildLimitedAvailability<Content: Node>(_ content: Content) -> ContentGroup {
        ContentGroup([content])
    }
}
