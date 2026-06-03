import Foundation

/// A value that can provide a namespace for an ontology alias.
public protocol AliasTarget: Sendable {
    /// Returns the namespace represented by this alias target.
    func aliasNamespace() throws -> Namespace
}

extension IRI: AliasTarget {
    /// Returns this IRI as a namespace target.
    public func aliasNamespace() throws -> Namespace {
        Namespace(rawValue)
    }
}

extension URL: AliasTarget {
    /// Returns this URL as a namespace target.
    public func aliasNamespace() throws -> Namespace {
        Namespace(absoluteString)
    }
}

extension URLComponents: AliasTarget {
    /// Returns this URL component value as a namespace target.
    public func aliasNamespace() throws -> Namespace {
        guard let string else {
            throw RDFTermError.invalidIRI("")
        }
        return Namespace(string)
    }
}

extension String: AliasTarget {
    /// Returns this string as a namespace target.
    public func aliasNamespace() throws -> Namespace {
        Namespace(self)
    }
}
