import Foundation

/// Ontology DSL content that contributes facts to the enclosing declaration.
protocol OntologyFactContent: Content {
    /// Adds this content's facts to the enclosing declaration facts.
    func addFacts(to facts: inout OntologyDeclarationFacts, in environment: OntologyEnvironment)
}
