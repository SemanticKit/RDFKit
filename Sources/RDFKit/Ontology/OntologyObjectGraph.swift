import Foundation

/// The object graph materialized from ontology DSL content.
struct OntologyObjectGraph: Equatable, Sendable {
    /// The ontology environment used to resolve scoped declarations.
    let environment: OntologyEnvironment

    /// IRI prefix mappings declared by ontology content.
    let aliases: [String: IRI]

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
        let environment = ContentNamespaceResolver.environment(in: content)

        self.environment = environment
        self.aliases = try Self.aliases(in: content)
        self.terms = try Self.termIRIs(in: content, environment: environment)
        self.classes = try Self.termIRIs(in: content, environment: environment, role: .class)
        self.properties = try Self.termIRIs(in: content, environment: environment, role: .property)
        self.datatypes = try Self.termIRIs(in: content, environment: environment, role: .datatype)
        self.individuals = try Self.termIRIs(in: content, environment: environment, role: .individual)
        self.facts = Self.facts(in: content, environment: environment)
    }

    /// Creates an object graph from an ontology value.
    init<OntologyValue: Ontology>(_ ontology: OntologyValue) throws {
        try self.init(content: ontology.content)
    }

    /// Creates an object graph from a vocabulary value.
    init<VocabularyValue: Vocabulary>(_ vocabulary: VocabularyValue) throws {
        try self.init(VocabularyValue.self)
    }

    /// Creates an object graph from a vocabulary type.
    init<VocabularyValue: Vocabulary>(_ vocabulary: VocabularyValue.Type) throws {
        try self.init(content: vocabulary.ontology)
    }

    /// Returns alias mappings declared in content.
    private static func aliases<ContentValue: Content>(in content: ContentValue) throws -> [String: IRI] {
        var aliases: [String: IRI] = [:]

        if let mappingContent = content as? any AliasMappingContent {
            try mappingContent.addIRIPrefixes(to: &aliases)
        }

        return aliases
    }

    /// Returns term IRIs declared by content.
    private static func termIRIs<ContentValue: Content>(
        in content: ContentValue,
        environment: OntologyEnvironment,
        role: OntologyDeclarationRole? = nil
    ) throws -> Set<IRI> {
        Set(try termIRIList(in: content, environment: environment, role: role))
    }

    /// Returns ordered term IRIs declared by content.
    private static func termIRIList(in content: any Content, environment: OntologyEnvironment, role: OntologyDeclarationRole?) throws -> [IRI] {
        var collected: [IRI] = []

        if let termContent = content as? any OntologyTermContent {
            collected.append(contentsOf: try termContent.termIRIs(in: environment, role: role))
        }
        if let term = content as? any RDFClass, role == nil || role == .class {
            collected.append(term.iri)
        }
        if let term = content as? any RDFProperty, role == nil || role == .property {
            collected.append(term.iri)
        }
        if let term = content as? any RDFDatatype, role == nil || role == .datatype {
            collected.append(term.iri)
        }
        if let term = content as? any RDFIndividual, role == nil || role == .individual {
            collected.append(term.iri)
        }
        if let term = content as? any Term, role == nil {
            collected.append(term.iri)
        }

        return collected
    }

    /// Returns declaration facts keyed by declaration IRI.
    private static func facts<ContentValue: Content>(
        in content: ContentValue,
        environment: OntologyEnvironment
    ) -> [IRI: OntologyDeclarationFacts] {
        var facts: [IRI: OntologyDeclarationFacts] = [:]

        if let declarationContent = content as? any OntologyDeclarationFactContent {
            declarationContent.addDeclarationFacts(to: &facts, in: environment)
        }

        return facts
    }
}
