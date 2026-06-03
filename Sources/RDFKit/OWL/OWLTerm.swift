import Foundation

/// A type-level term from the OWL vocabulary.
public protocol OWLTerm: MatrixBackedVocabularyTerm {}

public extension OWLTerm {
    /// The standards vocabulary label.
    static var vocabulary: String { "OWL" }

    /// The OWL namespace.
    static var namespace: Namespace { OWL.namespace }

    /// The OWL local name inferred from the Swift term type.
    static var localName: LocalName { LocalName(String(describing: Self.self)) }
}
