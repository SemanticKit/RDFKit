import Foundation

/// The object graph materialized from ontology DSL content.
public struct OntologyObjectGraph: Equatable, Sendable {
    /// A failure encountered while materializing ontology content.
    public enum Failure: Error, Equatable, Sendable {
        /// Declaration materialization exceeded the configured recursion bound.
        case maximumDepthExceeded(Int)

        /// Two merged object graphs declared different values for the same IRI.
        case duplicateDeclaration(IRI)

        /// Two merged object graphs declared different targets for the same alias prefix.
        case conflictingAlias(String)
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

    /// Dependency edges materialized from declaration facts and subclass/subproperty closure.
    public let dependencyEdges: [OntologyDependencyEdge]

    /// Transitive rdfs:subClassOf targets keyed by declaration IRI.
    public let transitiveSuperclasses: [IRI: Set<IRI>]

    /// Transitive rdfs:subPropertyOf targets keyed by declaration IRI.
    public let transitiveSuperproperties: [IRI: Set<IRI>]

    /// Creates an object graph from ontology content.
    public init<ContentValue: Content>(content: ContentValue) throws {
        try self.init(content: content, maximumDepth: 64)
    }

    /// Creates an object graph from ontology content with a bounded declaration depth.
    init<ContentValue: Content>(content: ContentValue, maximumDepth: Int) throws {
        let environment = ContentNamespaceResolver.environment(in: content)
        let declarations = try Self.declarations(in: content, environment: environment, maximumDepth: maximumDepth)
        let facts = Self.facts(in: declarations)
        let transitiveSuperclasses = Self.transitiveObjects(in: facts, over: \.superclasses)
        let transitiveSuperproperties = Self.transitiveObjects(in: facts, over: \.superproperties)
        let dependencyEdges = Self.dependencyEdges(
            in: facts,
            transitiveSuperclasses: transitiveSuperclasses,
            transitiveSuperproperties: transitiveSuperproperties
        )

        self.environment = environment
        self.declarations = declarations
        self.aliases = try Self.aliases(in: content)
        self.terms = try Self.termIRIs(in: content, environment: environment).union(declarations.iris)
        self.classes = try Self.termIRIs(in: content, environment: environment, role: .class).union(declarations.iris(for: .class))
        self.properties = try Self.termIRIs(in: content, environment: environment, role: .property).union(declarations.iris(for: .property))
        self.datatypes = try Self.termIRIs(in: content, environment: environment, role: .datatype).union(declarations.iris(for: .datatype))
        self.individuals = try Self.termIRIs(in: content, environment: environment, role: .individual).union(declarations.iris(for: .individual))
        self.facts = facts
        self.transitiveSuperclasses = transitiveSuperclasses
        self.transitiveSuperproperties = transitiveSuperproperties
        self.dependencyEdges = dependencyEdges
    }

    /// Creates an object graph from already materialized pieces.
    private init(
        environment: OntologyEnvironment,
        declarations: [OntologyDeclaration],
        aliases: [String: IRI],
        terms: Set<IRI>,
        classes: Set<IRI>,
        properties: Set<IRI>,
        datatypes: Set<IRI>,
        individuals: Set<IRI>
    ) {
        let facts = Self.facts(in: declarations)
        let transitiveSuperclasses = Self.transitiveObjects(in: facts, over: \.superclasses)
        let transitiveSuperproperties = Self.transitiveObjects(in: facts, over: \.superproperties)
        let dependencyEdges = Self.dependencyEdges(
            in: facts,
            transitiveSuperclasses: transitiveSuperclasses,
            transitiveSuperproperties: transitiveSuperproperties
        )

        self.environment = environment
        self.declarations = declarations
        self.aliases = aliases
        self.terms = terms
        self.classes = classes
        self.properties = properties
        self.datatypes = datatypes
        self.individuals = individuals
        self.facts = facts
        self.transitiveSuperclasses = transitiveSuperclasses
        self.transitiveSuperproperties = transitiveSuperproperties
        self.dependencyEdges = dependencyEdges
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

    /// Returns the declaration for an IRI-backed value.
    public func declaration<TermValue: IRIRepresentable>(for term: TermValue) -> OntologyDeclaration? {
        declarations.first { $0.iri == term.iri }
    }

    /// Returns the declaration for an IRI-backed type.
    public func declaration<TermType: TypeIRIRepresentable>(for term: TermType.Type) -> OntologyDeclaration? {
        declarations.first { $0.iri == TermType.iri }
    }

    /// Returns declaration facts for an IRI-backed value.
    public func facts<TermValue: IRIRepresentable>(for term: TermValue) -> OntologyDeclarationFacts? {
        facts[term.iri]
    }

    /// Returns declaration facts for an IRI-backed type.
    public func facts<TermType: TypeIRIRepresentable>(for term: TermType.Type) -> OntologyDeclarationFacts? {
        facts[TermType.iri]
    }

    /// Returns an object graph combining this graph with another graph.
    public func merging(with other: OntologyObjectGraph) throws -> OntologyObjectGraph {
        try OntologyObjectGraph(
            environment: environment,
            declarations: mergedDeclarations(with: other),
            aliases: mergedAliases(with: other),
            terms: terms.union(other.terms),
            classes: classes.union(other.classes),
            properties: properties.union(other.properties),
            datatypes: datatypes.union(other.datatypes),
            individuals: individuals.union(other.individuals)
        )
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

    /// Returns transitive object targets for one relationship.
    private static func transitiveObjects(
        in facts: [IRI: OntologyDeclarationFacts],
        over keyPath: KeyPath<OntologyDeclarationFacts, Set<IRI>>
    ) -> [IRI: Set<IRI>] {
        Dictionary(uniqueKeysWithValues: facts.keys.sorted().map { source in
            (source, transitiveObjects(from: source, in: facts, over: keyPath))
        })
    }

    /// Returns the transitive object closure for one fact relationship.
    private static func transitiveObjects(
        from source: IRI,
        in facts: [IRI: OntologyDeclarationFacts],
        over keyPath: KeyPath<OntologyDeclarationFacts, Set<IRI>>
    ) -> Set<IRI> {
        var visited: Set<IRI> = []
        var queue = Array(facts[source]?[keyPath: keyPath] ?? [])

        while let next = queue.first {
            queue.removeFirst()

            if visited.insert(next).inserted {
                queue.append(contentsOf: facts[next]?[keyPath: keyPath] ?? [])
            }
        }

        return visited
    }

    /// Returns dependency edges derived from declaration facts and closure.
    private static func dependencyEdges(
        in facts: [IRI: OntologyDeclarationFacts],
        transitiveSuperclasses: [IRI: Set<IRI>],
        transitiveSuperproperties: [IRI: Set<IRI>]
    ) -> [OntologyDependencyEdge] {
        var edges: Set<OntologyDependencyEdge> = []

        for source in facts.keys.sorted() {
            guard let fact = facts[source] else { continue }

            edges.formUnion(fact.types.map { OntologyDependencyEdge(source: source, kind: .type, target: $0) })
            edges.formUnion((transitiveSuperclasses[source] ?? []).map { OntologyDependencyEdge(source: source, kind: .subClassOf, target: $0) })
            edges.formUnion((transitiveSuperproperties[source] ?? []).map { OntologyDependencyEdge(source: source, kind: .subPropertyOf, target: $0) })
            edges.formUnion(fact.domains.map { OntologyDependencyEdge(source: source, kind: .domain, target: $0) })
            edges.formUnion(fact.ranges.map { OntologyDependencyEdge(source: source, kind: .range, target: $0) })
            edges.formUnion(fact.seeAlso.map { OntologyDependencyEdge(source: source, kind: .seeAlso, target: $0) })
            edges.formUnion(fact.isDefinedBy.map { OntologyDependencyEdge(source: source, kind: .isDefinedBy, target: $0) })
        }

        return edges.sorted()
    }

    /// Returns declarations from two graphs after validating duplicates.
    private func mergedDeclarations(with other: OntologyObjectGraph) throws -> [OntologyDeclaration] {
        var declarationsByIRI = Dictionary(uniqueKeysWithValues: declarations.map { ($0.iri, $0) })
        var merged = declarations

        for declaration in other.declarations {
            if let existing = declarationsByIRI[declaration.iri] {
                guard existing == declaration else {
                    throw Failure.duplicateDeclaration(declaration.iri)
                }
            } else {
                declarationsByIRI[declaration.iri] = declaration
                merged.append(declaration)
            }
        }

        return merged
    }

    /// Returns aliases from two graphs after validating conflicts.
    private func mergedAliases(with other: OntologyObjectGraph) throws -> [String: IRI] {
        var merged = aliases

        for (prefix, iri) in other.aliases {
            if let current = merged[prefix] {
                guard current == iri else {
                    throw Failure.conflictingAlias(prefix)
                }
            } else {
                merged[prefix] = iri
            }
        }

        return merged
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
