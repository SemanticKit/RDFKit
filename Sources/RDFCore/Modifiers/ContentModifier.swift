import Foundation

/// A type that transforms or augments authored RDF content.
///
/// Conforming types declare which node type they target via `ContentType`
/// and selectively apply transformations through `shouldApply(to:)` and
/// `apply(to:)`.
///
/// Use `ContentModifier` to build reusable, composable transformations
/// that can be applied during DSL composition or as post-processing
/// on a fully composed content tree.
public protocol ContentModifier<ContentType>: Sendable {

    /// The node type this modifier targets.
    associatedtype ContentType: Node

    /// Whether this modifier should apply to the given node.
    ///
    /// Return `true` to apply the modifier, `false` to skip it.
    /// The default implementation returns `true` for all nodes.
    func shouldApply(to node: any Node) -> Bool

    /// Applies the modifier to a node, returning the modified result.
    ///
    /// The return type is the same concrete type as the input, preserving
    /// type information for chaining.
    func apply<C: Node>(to content: C) -> C
}

// MARK: - Defaults

extension ContentModifier {

    public func shouldApply(to node: any Node) -> Bool {
        true
    }
}
