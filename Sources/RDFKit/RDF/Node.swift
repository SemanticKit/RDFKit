import Foundation

/// The most general RDF node protocol.
public protocol Node: Content, Hashable, CustomStringConvertible, Sendable {}

/// A node that may appear in the subject position of a triple.
public protocol Subject: Node {}

/// A node that may appear in the predicate position of a triple.
public protocol Predicate: Node {}

/// A node that may appear in the object position of a triple.
public protocol Object: Node {}
