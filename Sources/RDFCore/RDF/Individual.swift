import Foundation

// MARK: - Protocol

/// An RDF individual declaration.
///
/// From RDF: Individuals are instances of classes.
public protocol IndividualDeclaration: TermContent {
    /// The declared individual name.
    var name: String { get }

    /// The child annotations for this individual.
    var children: [any Node] { get }
}

// MARK: - DSL

/// Declares an RDF individual.
///
///     Individual("nil") {
///         Type(RDF.List)
///         Label("nil")
///     }
public func Individual(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}
