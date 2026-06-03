import Foundation

/// Ontology DSL content that contributes declarations during expansion.
protocol OntologyExpansionContent: Content {
    /// Adds expansion declarations contributed by this content.
    func addExpansionDeclarations(
        to declarations: inout [OntologyExpansionDeclaration],
        visited: inout Set<IRI>,
        environment: OntologyEnvironment,
        depth: Int,
        maximumDepth: Int
    ) throws
}

extension NamespaceScopedDeclaration {
    /// Adds this scoped declaration during expansion.
    func addExpansionDeclarations(
        to declarations: inout [OntologyExpansionDeclaration],
        visited: inout Set<IRI>,
        environment: OntologyEnvironment,
        depth: Int,
        maximumDepth: Int
    ) throws {
        try checkExpansionDepth(depth, maximumDepth: maximumDepth)

        let declarationIRI = iri(in: environment)

        guard visited.insert(declarationIRI).inserted else {
            return
        }

        declarations.append(OntologyExpansionDeclaration(
            iri: declarationIRI,
            localName: localName,
            role: role,
            facts: OntologyDeclarationFacts(content: bodyContent, environment: environment)
        ))

        if let expansionContent = bodyContent as? any OntologyExpansionContent {
            try expansionContent.addExpansionDeclarations(
                to: &declarations,
                visited: &visited,
                environment: environment,
                depth: depth + 1,
                maximumDepth: maximumDepth
            )
        }
    }
}

extension ContentGroup: OntologyExpansionContent {
    /// Adds expansion declarations contributed by grouped content.
    func addExpansionDeclarations(
        to declarations: inout [OntologyExpansionDeclaration],
        visited: inout Set<IRI>,
        environment: OntologyEnvironment,
        depth: Int,
        maximumDepth: Int
    ) throws {
        try checkExpansionDepth(depth, maximumDepth: maximumDepth)

        for element in elements {
            if let expansionContent = element as? any OntologyExpansionContent {
                try expansionContent.addExpansionDeclarations(
                    to: &declarations,
                    visited: &visited,
                    environment: environment,
                    depth: depth + 1,
                    maximumDepth: maximumDepth
                )
            }
        }
    }
}

/// Verifies bounded ontology expansion depth.
private func checkExpansionDepth(_ depth: Int, maximumDepth: Int) throws {
    guard depth <= maximumDepth else {
        throw OntologyExpansion.Failure.maximumDepthExceeded(maximumDepth)
    }
}
