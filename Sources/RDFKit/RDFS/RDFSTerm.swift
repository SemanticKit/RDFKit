import Foundation

/// A type-level term from the RDFS namespace.
public protocol RDFSTerm: NamespaceTerm, Content {}

public extension RDFSTerm {
    /// The RDFS namespace.
    static var namespace: Namespace { RDFS.declaredNamespace }

    /// The RDFS local name inferred from the Swift term type.
    static var localName: LocalName { LocalName(String(describing: Self.self)) }
}
