import Foundation

/// The most general RDF node protocol.
public protocol RDFNode: Content, Hashable, CustomStringConvertible, Sendable {}

/// A node that may appear in the subject position of a triple.
public protocol RDFSubject: RDFNode {}

/// A node that may appear in the predicate position of a triple.
public protocol RDFPredicate: RDFNode {}

/// A node that may appear in the object position of a triple.
public protocol RDFObject: RDFNode {}

extension RDFNode {
    /// The node rendered as N-Triples-compatible text when supported by the concrete type.
    public var ntriples: String { description }
}
