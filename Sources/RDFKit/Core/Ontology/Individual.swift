import Foundation

/// Declares an authored individual.
public struct Individual<Body: Content>: Content {
    /// The local individual name.
    let localName: LocalName

    /// The individual body content.
    let content: Body

    /// Creates an empty individual declaration.
    public init(_ localName: String) where Body == EmptyContent {
        self.localName = LocalName(localName)
        self.content = EmptyContent()
    }

    /// Creates an individual declaration.
    public init(_ localName: String, @ContentBuilder content: () -> Body) {
        self.localName = LocalName(localName)
        self.content = content()
    }
}
