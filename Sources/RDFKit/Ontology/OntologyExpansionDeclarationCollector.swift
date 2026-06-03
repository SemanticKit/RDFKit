import Foundation

/// Collects expansion declarations from ontology content.
struct OntologyExpansionDeclarationCollector: Sendable {
    /// The maximum recursive content depth expansion may traverse.
    let maximumDepth: Int

    /// Returns ordered declarations in ontology content.
    func declarations(in content: any Content, environment: OntologyEnvironment) throws -> [OntologyExpansionDeclaration] {
        var visited: Set<IRI> = []
        var declarations: [OntologyExpansionDeclaration] = []

        try collect(in: content, environment: environment, depth: 0, visited: &visited, declarations: &declarations)

        return declarations
    }

    /// Recursively collects declarations while tracking visited IRI identities.
    private func collect(
        in content: any Content,
        environment: OntologyEnvironment,
        depth: Int,
        visited: inout Set<IRI>,
        declarations: inout [OntologyExpansionDeclaration]
    ) throws {
        guard depth <= maximumDepth else {
            throw OntologyExpansion.Failure.maximumDepthExceeded(maximumDepth)
        }

        if let declaration = content as? any NamespaceScopedDeclaration {
            let iri = declaration.iri(in: environment)

            if visited.insert(iri).inserted {
                declarations.append(OntologyExpansionDeclaration(
                    iri: iri,
                    localName: declaration.localName,
                    role: declaration.role,
                    facts: ContentFactResolver.declarationFacts(in: declaration.bodyContent, environment: environment)
                ))
                try collect(
                    in: declaration.bodyContent,
                    environment: environment,
                    depth: depth + 1,
                    visited: &visited,
                    declarations: &declarations
                )
            }
        }

        if let group = content as? ContentGroup {
            for element in group.elements {
                try collect(
                    in: element,
                    environment: environment,
                    depth: depth + 1,
                    visited: &visited,
                    declarations: &declarations
                )
            }
        }
    }
}
