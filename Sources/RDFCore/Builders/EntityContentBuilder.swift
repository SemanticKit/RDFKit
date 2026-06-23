import Foundation

@resultBuilder
public enum EntityContentBuilder {
    public static func buildBlock() -> [any Entity] {
        []
    }

    public static func buildBlock<each T: Entity>(_ content: repeat each T) -> [any Entity] {
        var result: [any Entity] = []
        repeat result.append(each content)
        return result
    }

    public static func buildOptional(_ content: (any Entity)?) -> [any Entity] {
        content.map { [$0] } ?? []
    }

    public static func buildEither(first content: any Entity) -> [any Entity] {
        [content]
    }

    public static func buildEither(second content: any Entity) -> [any Entity] {
        [content]
    }

    public static func buildArray(_ components: [any Entity]) -> [any Entity] {
        components
    }

    public static func buildLimitedAvailability(_ content: any Entity) -> [any Entity] {
        [content]
    }
}
