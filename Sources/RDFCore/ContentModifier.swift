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

// MARK: - Post-Processing: Tree Walking

extension ContentModifier {

    /// Applies this modifier recursively to a content tree.
    ///
    /// Walks children depth-first, applying the modifier
    /// at each node where `shouldApply(to:)` returns `true`.
    public func applyRecursively<C: Node>(to content: C) -> any Node {
        Self.walk(content, modifier: self)
    }

    private static func walk(
        _ node: any Node,
        modifier: some ContentModifier
    ) -> any Node {
        var modified: any Node = node

        if modifier.shouldApply(to: node) {
            modified = modifier.apply(to: node)
        }

        if let decl = modified as? TermDeclaration {
            let newChildren = decl.children.map { walk($0, modifier: modifier) }
            modified = TermDeclaration(kind: decl.kind, name: decl.name, children: newChildren)
        }

        return modified
    }
}

/// Applies a modifier recursively to a content tree.
///
/// Use this to transform an entire composed content tree after the
/// result builder has finished:
/// ```swift
/// let ontology = MyOntology()
/// let modified = applyModifier(AddLabel("en"), to: ontology.content)
/// ```
public func applyModifier<M: ContentModifier>(
    _ modifier: M,
    to content: some Node
) -> any Node {
    modifier.applyRecursively(to: content)
}
