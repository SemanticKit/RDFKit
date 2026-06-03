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
}
