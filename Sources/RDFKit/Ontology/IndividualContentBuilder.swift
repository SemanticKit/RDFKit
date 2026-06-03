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
}
