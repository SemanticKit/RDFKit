import Foundation

/// The object graph materialized from ontology DSL content.
public struct OntologyObjectGraph: Equatable, Sendable {
    /// A failure encountered while materializing ontology content.
    public enum Failure: Error, Equatable, Sendable {
        /// Declaration materialization exceeded the configured recursion bound.
        case maximumDepthExceeded(Int)
    }

    /// The ontology environment used to resolve scoped declarations.
    public let environment: OntologyEnvironment

    /// Ordered declarations materialized from ontology content.
    public let declarations: [OntologyDeclaration]

    /// IRI prefix mappings declared by ontology content.
    public let aliases: [String: IRI]

    /// All declared term IRIs.
    public let terms: Set<IRI>

    /// Declared class IRIs.
    public let classes: Set<IRI>

    /// Declared property IRIs.
    public let properties: Set<IRI>

    /// Declared datatype IRIs.
    public let datatypes: Set<IRI>

    /// Declared individual IRIs.
    public let individuals: Set<IRI>

    /// Declaration facts keyed by declaration IRI.
    public let facts: [IRI: OntologyDeclarationFacts]

    /// Creates an object graph from ontology content.
    public init<ContentValue: Content>(content: ContentValue) throws {
        try self.init(content: content, maximumDepth: 64)
    }

    /// Creates an object graph from ontology content with a bounded declaration depth.
    init<ContentValue: Content>(content: ContentValue, maximumDepth: Int) throws {
        let environment = ContentNamespaceResolver.environment(in: content)
        let declarations = try Self.declarations(in: content, environment: environment, maximumDepth: maximumDepth)

        self.environment = environment
        self.declarations = declarations
        self.aliases = try Self.aliases(in: content)
        self.terms = try Self.termIRIs(in: content, environment: environment).union(declarations.iris)
        self.classes = try Self.termIRIs(in: content, environment: environment, role: .class).union(declarations.iris(for: .class))
        self.properties = try Self.termIRIs(in: content, environment: environment, role: .property).union(declarations.iris(for: .property))
        self.datatypes = try Self.termIRIs(in: content, environment: environment, role: .datatype).union(declarations.iris(for: .datatype))
        self.individuals = try Self.termIRIs(in: content, environment: environment, role: .individual).union(declarations.iris(for: .individual))
        self.facts = Self.facts(in: declarations)
    }

    /// Creates an object graph from an ontology value.
    public init<OntologyValue: Ontology>(_ ontology: OntologyValue) throws {
        try self.init(content: ontology.content)
    }

    /// Creates an object graph from a vocabulary value.
    public init<VocabularyValue: Vocabulary>(_ vocabulary: VocabularyValue) throws {
        try self.init(VocabularyValue.self)
    }

    /// Creates an object graph from a vocabulary type.
    public init<VocabularyValue: Vocabulary>(_ vocabulary: VocabularyValue.Type) throws {
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

    /// Returns ordered declarations materialized from content.
    private static func declarations<ContentValue: Content>(
        in content: ContentValue,
        environment: OntologyEnvironment,
        maximumDepth: Int
    ) throws -> [OntologyDeclaration] {
        var visited: Set<IRI> = []
        var declarations: [OntologyDeclaration] = []

        if let declarationContent = content as? any OntologyDeclarationContent {
            try declarationContent.addOntologyDeclarations(
                to: &declarations,
                visited: &visited,
                environment: environment,
                depth: 0,
                maximumDepth: maximumDepth
            )
        }

        return declarations
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
    private static func facts(in declarations: [OntologyDeclaration]) -> [IRI: OntologyDeclarationFacts] {
        Dictionary(uniqueKeysWithValues: declarations.map { ($0.iri, $0.facts) })
    }
}

private extension Array where Element == OntologyDeclaration {
    /// All declaration IRIs.
    var iris: Set<IRI> {
        Set(map(\.iri))
    }

    /// Returns declaration IRIs matching the requested role.
    func iris(for role: OntologyDeclarationRole) -> Set<IRI> {
        Set(filter { $0.role == role }.map(\.iri))
    }
}
