import Foundation

/// Ontology content for one standards vocabulary derived from the RDF standards matrix.
public struct StandardVocabularyContent: OntologyContent, GraphContent {
    /// The standards vocabulary label.
    public let vocabulary: String

    /// The vocabulary namespace.
    public let namespace: Namespace

    /// Creates standards vocabulary content.
    public init(vocabulary: String, namespace: Namespace) {
        self.vocabulary = vocabulary
        self.namespace = namespace
    }

    /// Returns all matrix-backed term declarations in this vocabulary.
    public func declarations() throws -> [StandardTermDeclaration] {
        try StandardsMatrix.bundled().entries(in: vocabulary).map(StandardTermDeclaration.init(entry:))
    }

    /// Returns the matrix-backed declaration for a local name.
    public func declaration(named localName: LocalName) throws -> StandardTermDeclaration {
        let iri = QualifiedName(namespace: namespace, localName: localName).iri
        guard let entry = try StandardsMatrix.bundled().entry(for: iri), entry.namespace == vocabulary else {
            throw RDFTermError.invalidIRI(iri.rawValue)
        }
        return StandardTermDeclaration(entry: entry)
    }

    /// Returns the matrix-backed declaration for a local name.
    public func declaration(named localName: String) throws -> StandardTermDeclaration {
        try declaration(named: LocalName(localName))
    }

    /// Writes all vocabulary declarations into a graph.
    public func write(to graph: inout Graph) throws {
        for declaration in try declarations() {
            try declaration.write(to: &graph)
        }
    }
}
