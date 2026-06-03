import Foundation

/// Expands ontology declaration DSL content into Swift term type source.
public struct OntologyExpansion: Sendable {
    /// The access level emitted for generated term declarations.
    public enum Access: Sendable {
        /// Emit public declarations.
        case `public`

        /// Emit internal declarations.
        case `internal`

        /// The Swift access keyword emitted into generated source.
        var keyword: String {
            switch self {
            case .public:
                "public"
            case .internal:
                "internal"
            }
        }
    }

    /// A failure encountered while expanding ontology content.
    public enum Failure: Error, Equatable, Sendable {
        /// Expansion exceeded the configured recursion bound.
        case maximumDepthExceeded(Int)

        /// A local name could not be converted into a Swift type identifier.
        case invalidSwiftTypeName(String)
    }

    /// The access level emitted for generated term declarations.
    public let access: Access

    /// The expression emitted for each generated term's owning ontology.
    public let ontologyExpression: String?

    /// The maximum recursive content depth expansion may traverse.
    public let maximumDepth: Int

    /// Creates an ontology expansion.
    public init(access: Access = .public, ontologyExpression: String? = nil, maximumDepth: Int = 64) {
        self.access = access
        self.ontologyExpression = ontologyExpression
        self.maximumDepth = maximumDepth
    }

    /// Returns Swift source for the ontology terms declared by DSL content.
    public func source<OntologyValue: Ontology>(for ontology: OntologyValue) throws -> String {
        let declarations = try OntologyExpansionDeclarationCollector(maximumDepth: maximumDepth)
            .declarations(in: ontology.content, environment: ontology.environment)
        let ontologyExpression = ontologyExpression ?? "\(OntologyValue.self)()"

        return try OntologyExpansionSourceRenderer(
            access: access,
            ontologyExpression: ontologyExpression,
            ontologyTypeName: String(describing: OntologyValue.self)
        )
            .source(for: declarations)
    }

    /// Returns a complete Swift source file for the ontology terms declared by DSL content.
    public func sourceFile<OntologyValue: Ontology>(
        for ontology: OntologyValue,
        imports: [String] = ["RDFKit"]
    ) throws -> String {
        try sourceFile(imports: imports, body: source(for: ontology))
    }

    /// Returns Swift source for the terms declared by a vocabulary's ontology content.
    public func source<VocabularyValue: Vocabulary>(for vocabulary: VocabularyValue.Type) throws -> String {
        let environment = ContentNamespaceResolver.environment(in: VocabularyValue.ontology)
        let declarations = try OntologyExpansionDeclarationCollector(maximumDepth: maximumDepth)
            .declarations(in: VocabularyValue.ontology, environment: environment)

        return try OntologyExpansionSourceRenderer(access: access, ontologyExpression: "", ontologyTypeName: "")
            .vocabularySource(for: declarations, vocabularyName: String(describing: VocabularyValue.self))
    }

    /// Returns Swift source for the terms declared by a vocabulary value's ontology content.
    public func source<VocabularyValue: Vocabulary>(for vocabulary: VocabularyValue) throws -> String {
        try source(for: VocabularyValue.self)
    }

    /// Returns a complete Swift source file for the terms declared by a vocabulary's ontology content.
    public func sourceFile<VocabularyValue: Vocabulary>(
        for vocabulary: VocabularyValue.Type,
        imports: [String] = ["RDFKit"]
    ) throws -> String {
        try sourceFile(imports: imports, body: source(for: vocabulary))
    }

    /// Returns a complete Swift source file for the terms declared by a vocabulary value's ontology content.
    public func sourceFile<VocabularyValue: Vocabulary>(
        for vocabulary: VocabularyValue,
        imports: [String] = ["RDFKit"]
    ) throws -> String {
        try sourceFile(for: VocabularyValue.self, imports: imports)
    }

    private func sourceFile(imports: [String], body: String) throws -> String {
        let importSource = imports.map { "import \($0)" }.joined(separator: "\n")

        guard importSource.isEmpty == false else {
            return body
        }

        return """
        \(importSource)

        \(body)
        """
    }
}
