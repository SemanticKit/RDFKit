import Foundation

/// A type-level term from a namespace.
public protocol NamespaceTerm: Term, TypeIRIRepresentable {
    /// The term namespace.
    static var namespace: Namespace { get }

    /// The term local name.
    static var localName: LocalName { get }

    /// Creates the term value.
    init()
}

extension NamespaceTerm {
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
