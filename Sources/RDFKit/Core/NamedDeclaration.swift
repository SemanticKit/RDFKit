import Foundation

/// A named declaration authored inside an ontology.
public struct NamedDeclaration<Role, Body: Content>: Content {
    let name: String
    let content: Body

    public init(_ name: String) where Body == EmptyContent {
        self.name = name
        self.content = EmptyContent()
    }

    public init(_ name: String, @ContentBuilder content: () -> Body) {
        self.name = name
        self.content = content()
    }
}
