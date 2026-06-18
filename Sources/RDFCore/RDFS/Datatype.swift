import Foundation

// MARK: - Protocol

/// An RDF datatype declaration.
///
/// From RDFS: The class of datatypes.
public protocol DatatypeDeclaration: TermContent {
    /// The declared datatype name.
    var name: String { get }

    /// The child annotations for this datatype.
    var children: [any Node] { get }
}

// MARK: - DSL

/// Declares an RDF datatype.
///
///     Datatype("langString") {
///         Type(RDFS.Datatype)
///         SubClassOf(RDFS.Literal)
///         Label("langString")
///     }
public func Datatype(
    _ name: String,
    @TermContentBuilder children: () -> [any Node]
) -> TermDeclaration {
    TermDeclaration(name: name, children: children())
}
