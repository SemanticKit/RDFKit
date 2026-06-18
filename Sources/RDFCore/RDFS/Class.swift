import Foundation

// MARK: - Protocol

/// An RDF class declaration.
///
/// From RDFS: The class of resources that are RDF classes.
public protocol ClassDeclaration: TermContent {
    /// The declared class name.
    var name: String { get }

    /// The child annotations for this class.
    var children: [any Node] { get }
}

// MARK: - DSL

/// Declares an RDF class.
///
///     Class("Resource") {
///         Type(RDFS.Class)
///         Label("Resource")
///         Comment("The class resource, everything.")
///     }
public func Class(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}
