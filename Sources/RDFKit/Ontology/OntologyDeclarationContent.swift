import Foundation

/// Ontology DSL content that contributes materialized declarations.
protocol OntologyDeclarationContent: Content {
    /// Adds declarations contributed by this content.
    func addOntologyDeclarations(
        to declarations: inout [OntologyDeclaration],
        visited: inout Set<IRI>,
        environment: OntologyEnvironment,
        depth: Int,
        maximumDepth: Int
    ) throws
}

extension NamespaceScopedDeclaration {
    /// Adds this scoped declaration to the materialized declaration list.
    func addOntologyDeclarations(
        to declarations: inout [OntologyDeclaration],
        visited: inout Set<IRI>,
        environment: OntologyEnvironment,
        depth: Int,
        maximumDepth: Int
    ) throws {
        try checkDeclarationDepth(depth, maximumDepth: maximumDepth)

        let declarationIRI = iri(in: environment)

        guard visited.insert(declarationIRI).inserted else {
            return
        }

        declarations.append(OntologyDeclaration(
            iri: declarationIRI,
            localName: localName,
            role: role,
            facts: OntologyDeclarationFacts(content: bodyContent, environment: environment)
        ))

        if let declarationContent = bodyContent as? any OntologyDeclarationContent {
            try declarationContent.addOntologyDeclarations(
                to: &declarations,
                visited: &visited,
                environment: environment,
                depth: depth + 1,
                maximumDepth: maximumDepth
            )
        }
    }
}

extension ContentGroup: OntologyDeclarationContent {
    /// Adds declarations contributed by grouped content.
    func addOntologyDeclarations(
        to declarations: inout [OntologyDeclaration],
        visited: inout Set<IRI>,
        environment: OntologyEnvironment,
        depth: Int,
        maximumDepth: Int
    ) throws {
        try checkDeclarationDepth(depth, maximumDepth: maximumDepth)

        for element in elements {
            if let declarationContent = element as? any OntologyDeclarationContent {
                try declarationContent.addOntologyDeclarations(
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

/// Verifies bounded ontology declaration materialization depth.
private func checkDeclarationDepth(_ depth: Int, maximumDepth: Int) throws {
    guard depth <= maximumDepth else {
        throw OntologyObjectGraph.Failure.maximumDepthExceeded(maximumDepth)
    }
}
