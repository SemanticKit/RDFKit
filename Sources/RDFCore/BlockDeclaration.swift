import Foundation

/// A declaration that contains nested authored content.
public struct BlockDeclaration<Role, Body: Content>: Content {
    /// The block's nested authored content.
    public let content: Body

    public init(@ContentBuilder content: () -> Body) {
        self.content = content()
    }
}
