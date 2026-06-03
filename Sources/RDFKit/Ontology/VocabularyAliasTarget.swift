import Foundation

/// An alias target resolved through a vocabulary type's ontology content.
public struct VocabularyAliasTarget<VocabularyValue: Vocabulary>: AliasTarget {
    /// The vocabulary type used as the alias target.
    public let vocabulary: VocabularyValue.Type

    /// Creates a vocabulary alias target.
    public init(_ vocabulary: VocabularyValue.Type) {
        self.vocabulary = vocabulary
    }

    /// Returns the namespace declared by the vocabulary's ontology content.
    public func aliasNamespace() throws -> Namespace {
        VocabularyValue.declaredNamespace
    }
}
