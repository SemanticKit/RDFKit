import Foundation

/// Declares an authored property.
public struct Property<Body: Content>: Content {
    /// The local property name.
    let localName: LocalName

    /// The property body content.
    let content: Body

    /// Creates an empty property declaration.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates a property declaration.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
