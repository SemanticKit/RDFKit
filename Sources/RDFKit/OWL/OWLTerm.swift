import Foundation

/// A type-level term from the OWL namespace.
public protocol OWLTerm: NamespaceTerm, Content {}

public extension OWLTerm {
    /// The OWL namespace.
    static var namespace: Namespace { OWL.declaredNamespace }

    /// The OWL local name inferred from the Swift term type.
    static var localName: LocalName { LocalName(String(describing: Self.self)) }
}
