import Foundation

/// Ontology alias content.
public protocol AliasContent: Sendable {}

/// An empty alias content value.
public struct EmptyAliasContent: AliasContent {
    /// Creates empty alias content.
    public init() {}
}

/// A prefix alias bound to a namespace target.
public struct Alias<Target: AliasTarget>: AliasContent {
    /// The alias prefix.
    public let prefix: String

    /// The target namespace value.
    public let target: Target

    /// Creates a prefix alias.
    public init(_ prefix: String, _ target: Target) {
        self.prefix = prefix
        self.target = target
    }
}

/// A group of alias content values.
public struct AliasGroup: AliasContent {
    /// The alias content values.
    public let elements: [any AliasContent]

    /// Creates an alias group.
    public init(_ elements: [any AliasContent]) {
        self.elements = elements
    }
}

/// Builds protocol-based alias content.
@resultBuilder
public enum AliasBuilder {
    public static func buildBlock() -> EmptyAliasContent {
        EmptyAliasContent()
    }

    public static func buildBlock<Content: AliasContent>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock(_ content: any AliasContent...) -> AliasGroup {
        AliasGroup(content)
    }
}
