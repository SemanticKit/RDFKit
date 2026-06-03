import Foundation

/// The object graph materialized from ontology DSL content.
struct OntologyObjectGraph: Equatable, Sendable {
    /// The ontology environment used to resolve scoped declarations.
    let environment: OntologyEnvironment

    /// All declared term IRIs.
    let terms: Set<IRI>

    /// Declared class IRIs.
    let classes: Set<IRI>

    /// Declared property IRIs.
    let properties: Set<IRI>

    /// Declared datatype IRIs.
    let datatypes: Set<IRI>

    /// Declared individual IRIs.
    let individuals: Set<IRI>

    /// Declaration facts keyed by declaration IRI.
    let facts: [IRI: OntologyDeclarationFacts]

    /// Creates an object graph from ontology content.
    init<ContentValue: Content>(content: ContentValue) throws {
        self.environment = ContentNamespaceResolver.environment(in: content)
        self.terms = try ContentTermResolver.termIRIs(in: content)
        self.classes = try ContentTermResolver.classIRIs(in: content)
        self.properties = try ContentTermResolver.propertyIRIs(in: content)
        self.datatypes = try ContentTermResolver.datatypeIRIs(in: content)
        self.individuals = try ContentTermResolver.individualIRIs(in: content)
        self.facts = ContentFactResolver.facts(in: content)
    }

    /// Creates an object graph from an ontology value.
    init<OntologyValue: Ontology>(_ ontology: OntologyValue) throws {
        try self.init(content: ontology.content)
    }
}
