import Foundation

/// Collects expansion declarations from ontology content.
struct OntologyExpansionDeclarationCollector: Sendable {
    /// The maximum recursive content depth expansion may traverse.
    let maximumDepth: Int

    /// Returns ordered declarations in ontology content.
    func declarations(in content: any Content, environment: OntologyEnvironment) throws -> [OntologyExpansionDeclaration] {
        var visited: Set<IRI> = []
        var declarations: [OntologyExpansionDeclaration] = []

        if let expansionContent = content as? any OntologyExpansionContent {
            try expansionContent.addExpansionDeclarations(
                to: &declarations,
                visited: &visited,
                environment: environment,
                depth: 0,
                maximumDepth: maximumDepth
            )
        }

        return declarations
    }
}
