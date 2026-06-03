import Foundation

/// Ontology DSL content that contributes term identities.
protocol OntologyTermContent: Content {
    /// Returns the term IRIs contributed by this content.
    func termIRIs(in environment: OntologyEnvironment, role: OntologyDeclarationRole?) throws -> [IRI]
}
