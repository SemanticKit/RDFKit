import Foundation

/// Builds ontology-level content (declarations: Class, Property, Prefix, etc.).
@resultBuilder
public enum ContentBuilder {
    public static func buildBlock() -> [any Node] {
        []
    }

    public static func buildBlock<each T: Node>(_ content: repeat each T) -> [any Node] {
        var result: [any Node] = []
        repeat result.append(each content)
        return result
    }

    public static func buildOptional(_ content: (any Node)?) -> [any Node] {
        content.map { [$0] } ?? []
    }

    public static func buildEither(first content: any Node) -> [any Node] {
        [content]
    }

    public static func buildEither(second content: any Node) -> [any Node] {
        [content]
    }

    public static func buildArray(_ components: [any Node]) -> [any Node] {
        components
    }

    public static func buildLimitedAvailability(_ content: any Node) -> [any Node] {
        [content]
    }
}
