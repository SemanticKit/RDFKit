import Foundation

// MARK: - Composition-Time Application

extension Node {

    /// Applies a modifier to this node.
    ///
    /// Enables trailing syntax on any DSL node:
    /// ```swift
    /// Class("Foo") {
    ///     Type(RDFS.Class)
    /// }.modifier(AddLabel("Foo", language: "en"))
    /// ```
    public func modifier<M: ContentModifier>(
        _ modifier: M
    ) -> any Node where M.ContentType == Self {
        guard modifier.shouldApply(to: self) else { return self }
        return modifier.apply(to: self)
    }

    /// Applies a sequence of modifiers to this node.
    ///
    /// Enables clean multi-modifier composition:
    /// ```swift
    /// Class("Foo") {
    ///     Type(RDFS.Class)
    /// }.with(
    ///     AddLabel("Foo", language: "en"),
    ///     AddComment("A foo class.", language: "en")
    /// )
    /// ```
    public func with(_ modifiers: any ContentModifier<Node>...) -> any Node {
        var result: any Node = self
        for modifier in modifiers {
            guard modifier.shouldApply(to: result) else { continue }
            result = modifier.apply(to: result)
        }
        return result
    }
}
