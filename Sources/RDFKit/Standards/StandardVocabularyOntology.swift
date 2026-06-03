import Foundation

/// A standards vocabulary expressed as protocol-first ontology DSL content.
public struct StandardVocabularyOntology<Aliases: AliasContent>: Ontology {
    /// The standards vocabulary label.
    public let vocabulary: String

    /// The ontology namespace.
    public let namespace: Namespace

    private let aliasContent: Aliases

    /// Creates a standards vocabulary ontology.
    public init(vocabulary: String, namespace: Namespace, @AliasBuilder aliases: () -> Aliases) {
        self.vocabulary = vocabulary
        self.namespace = namespace
        self.aliasContent = aliases()
    }

    /// Prefix and namespace aliases used by the vocabulary.
    public var aliases: Aliases {
        aliasContent
    }

    /// Matrix-backed standards vocabulary content.
    public var content: StandardVocabularyContent {
        StandardVocabularyContent(vocabulary: vocabulary, namespace: namespace)
    }
}
