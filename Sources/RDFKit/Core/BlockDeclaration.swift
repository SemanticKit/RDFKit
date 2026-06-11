import Foundation

/// A declaration that contains nested authored content.
public struct BlockDeclaration<Role, Body: Content>: Content {
    let content: Body

    public init(@ContentBuilder content: () -> Body) {
        self.content = content()
    }
}
