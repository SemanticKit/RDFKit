import Foundation

/// A vocabulary term whose full RDF declaration is backed by the standards matrix.
public protocol MatrixBackedVocabularyTerm: VocabularyTerm, OntologyContent, GraphContent {
    /// The standards vocabulary label that owns this term.
    static var vocabulary: String { get }
}

extension MatrixBackedVocabularyTerm {
    /// The standards matrix declaration for this term.
    public static var declaration: StandardTermDeclaration {
        get throws {
            try StandardTermDeclaration(namespace: namespace, localName: localName, vocabulary: vocabulary)
        }
    }

    /// Writes this term declaration into a graph.
    public func write(to graph: inout Graph) throws {
        try Self.declaration.write(to: &graph)
    }
}
