import Foundation

/// Ontology DSL content that contributes namespace declarations.
protocol OntologyNamespaceContent: Content {
    /// The namespace declarations contributed by this content.
    var declaredNamespaces: [Namespace] { get }
}
