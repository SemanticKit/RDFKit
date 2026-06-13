import Foundation

/// A named declaration authored inside an ontology.
public struct NamedDeclaration<Role, Body: Content>: Content {
    /// The authored declaration name.
    public let name: String

    /// The declaration's nested authored content.
    public let content: Body

    public init(_ name: String) where Body == EmptyContent {
        self.name = name
        self.content = EmptyContent()
    }

    public init(_ name: String, @ContentBuilder content: () -> Body) {
        self.name = name
        self.content = content()
    }
}
