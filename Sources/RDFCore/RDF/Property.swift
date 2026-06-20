import Foundation


// MARK: - Protocol


// MARK: - DSL

/// Declares an RDF property.
///
///     Property("label") {
///         Type(RDF.Property)
///         Domain(RDFS.Resource)
///         Range(RDFS.Literal)
///         Label("label")
///     }
//public func Property(
//    _ name: String,
//    @TermContentBuilder children: () -> [any Node]
//) -> TermDeclaration {
//    TermDeclaration(name: name, children: children())
//}
