import Foundation

/// Groups annotation facts as authored content.
public struct Annotation<Body: Content>: Content {
    /// The grouped annotation content.
    let content: Body

    /// Creates an annotation block.
    public init(@ContentBuilder content: () -> Body) {
        self.content = content()
    }
}
