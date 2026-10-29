import Foundation

/// Builds ontology content: declarations (``Class``, ``Property``,
/// ``Datatype``, ``Individual``), their annotations, prefixes and namespaces.
///
/// Every statement in a builder body is an ``Entity`` value. Each one is lifted
/// into ``Content`` by `buildExpression`, so `if`, `if`/`else`, `for` and
/// availability checks compose without a fixed arity.
@resultBuilder
public enum ContentBuilder {
    public static func buildExpression<Value: Entity>(_ expression: Value) -> Content {
        [expression]
    }

    public static func buildBlock(_ components: Content...) -> Content {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: Content?) -> Content {
        component ?? []
    }

    public static func buildEither(first component: Content) -> Content {
        component
    }

    public static func buildEither(second component: Content) -> Content {
        component
    }

    public static func buildArray(_ components: [Content]) -> Content {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: Content) -> Content {
        component
    }
}
