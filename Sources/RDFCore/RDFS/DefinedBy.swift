import Foundation

/// A type that declares the namespace in which its vocabulary is defined.
public protocol DefinedBy {
    /// Associates a namespace with the content produced by this type.
    mutating func isDefinedBy<Content>(_ namespace: Content)
}
