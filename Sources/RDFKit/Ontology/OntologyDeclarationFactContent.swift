import Foundation

/// Ontology DSL content that contributes declaration facts.
protocol OntologyDeclarationFactContent: Content {
    /// Adds this content's declaration facts to the declaration fact map.
    func addDeclarationFacts(to facts: inout [IRI: OntologyDeclarationFacts], in environment: OntologyEnvironment)
}
