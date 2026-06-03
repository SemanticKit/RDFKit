import Foundation

/// A DSL type that represents an RDF vocabulary.
public protocol Vocabulary: Content, IRIRepresentable, TypeIRIRepresentable {
    associatedtype Body: Content

    /// The vocabulary ontology content.
    @ContentBuilder static var ontology: Body { get }
}

/// A vocabulary whose terms are provided by the bundled standards matrix.
protocol StandardsVocabulary: Vocabulary {
    /// The standards matrix label for this vocabulary.
    static var standardsLabel: String { get }
}

extension StandardsVocabulary {
    /// The standards matrix label for this vocabulary value.
    var standardsLabel: String { Self.standardsLabel }
}

public extension Vocabulary {
    /// The vocabulary identity.
    static var iri: IRI { ContentNamespaceResolver.namespace(in: ontology).iri }

    /// The vocabulary identity.
    var iri: IRI { Self.iri }
}

extension Vocabulary {
    /// The vocabulary namespace declared by its ontology content.
    static var declaredNamespace: Namespace {
        ContentNamespaceResolver.namespace(in: ontology)
    }
}
