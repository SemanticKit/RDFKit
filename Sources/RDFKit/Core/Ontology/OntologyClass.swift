import Foundation

/// Declares an authored class.
public struct Class<Body: Content>: Content {
    /// The local class name.
    let localName: LocalName

    /// The class body content.
    let content: Body

    /// Creates an empty class declaration.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates a class declaration.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
