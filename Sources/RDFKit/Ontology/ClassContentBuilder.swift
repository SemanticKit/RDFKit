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
}
