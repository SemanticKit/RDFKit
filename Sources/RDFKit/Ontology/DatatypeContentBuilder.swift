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
}
