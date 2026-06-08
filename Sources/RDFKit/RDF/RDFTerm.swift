import Foundation

/// A type-level term from the RDF namespace.
public protocol RDFTerm: NamespaceTerm, Content {}

public extension RDFTerm {
    /// The RDF namespace.
    static var namespace: Namespace { RDF.declaredNamespace }

    /// The RDF local name inferred from the Swift term type.
    static var localName: LocalName { LocalName(String(describing: Self.self)) }
}
