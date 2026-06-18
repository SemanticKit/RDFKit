import Foundation

// MARK: - Protocol

/// An RDF property declaration.
///
/// From RDF: The class of RDF properties.
public protocol PropertyDeclaration: TermContent {
    /// The declared property name.
    var name: String { get }

    /// The child annotations for this property.
    var children: [any Node] { get }
}

// MARK: - DSL

/// Declares an RDF property.
///
///     Property("label") {
///         Type(RDF.Property)
///         Domain(RDFS.Resource)
///         Range(RDFS.Literal)
///         Label("label")
///     }
public func Property(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}
