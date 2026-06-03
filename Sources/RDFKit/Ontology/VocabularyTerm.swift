import Foundation

/// A type-level term from a vocabulary namespace.
public protocol VocabularyTerm: Term, TypeIRIRepresentable {
    /// The vocabulary namespace.
    static var namespace: Namespace { get }

    /// The vocabulary local name.
    static var localName: LocalName { get }

    /// Creates the vocabulary term value.
    init()
}

extension VocabularyTerm {
    /// The term namespace-qualified name.
    public static var qualifiedName: QualifiedName {
        QualifiedName(namespace: namespace, localName: localName)
    }

    /// The term IRI.
    public static var iri: IRI {
        qualifiedName.iri
    }

    /// The term IRI.
    public var iri: IRI {
        Self.iri
    }

}
