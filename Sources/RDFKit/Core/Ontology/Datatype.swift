import Foundation

/// Declares an authored datatype.
public struct Datatype<Body: Content>: Content {
    /// The local datatype name.
    let localName: LocalName

    /// The datatype body content.
    let content: Body

    /// Creates an empty datatype declaration.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates a datatype declaration.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
