import Foundation

/// A type-level term from the RDFS vocabulary.
public protocol RDFSTerm: MatrixBackedVocabularyTerm {}

public extension RDFSTerm {
    /// The standards vocabulary label.
    static var vocabulary: String { "RDFS" }

    /// The RDFS namespace.
    static var namespace: Namespace { RDFS.namespace }

    /// The RDFS local name inferred from the Swift term type.
    static var localName: LocalName { LocalName(String(describing: Self.self)) }
}
