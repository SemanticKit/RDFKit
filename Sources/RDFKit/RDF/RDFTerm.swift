import Foundation

/// A type-level term from the RDF vocabulary.
public protocol RDFTerm: MatrixBackedVocabularyTerm {}

public extension RDFTerm {
    /// The standards vocabulary label.
    static var vocabulary: String { "RDF" }

    /// The RDF namespace.
    static var namespace: Namespace { RDF.namespace }

    /// The RDF local name inferred from the Swift term type.
    static var localName: LocalName { LocalName(String(describing: Self.self)) }
}
