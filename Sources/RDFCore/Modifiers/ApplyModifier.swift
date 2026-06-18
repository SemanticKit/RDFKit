import Foundation

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
            modified = TermDeclaration(name: decl.name, children: newChildren)
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
