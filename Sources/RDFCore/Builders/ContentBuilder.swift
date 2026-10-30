import Foundation

/// Builds ontology content: declarations (``Class``, ``Property``,
/// ``Datatype``), their annotations, prefixes and namespaces.
///
/// Every statement in a builder body is an ``Entity`` value. Each one is lifted
/// into ``Entities`` by `buildExpression`, so `if`, `if`/`else`, `for` and
/// availability checks compose without a fixed arity.
@resultBuilder
public enum ContentBuilder {
    public static func buildExpression<Value: Entity>(_ expression: Value) -> Entities {
        [expression]
    }

    public static func buildBlock(_ components: Entities...) -> Entities {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: Entities?) -> Entities {
        component ?? []
    }

    public static func buildEither(first component: Entities) -> Entities {
        component
    }

    public static func buildEither(second component: Entities) -> Entities {
        component
    }

    public static func buildArray(_ components: [Entities]) -> Entities {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: Entities) -> Entities {
        component
    }
}
