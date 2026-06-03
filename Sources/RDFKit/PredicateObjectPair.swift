import Foundation

/// A predicate and object pair used as attached RDF statement content.
public struct PredicateObjectPair: Hashable, Sendable {
    /// The predicate IRI.
    public let predicate: IRI

    /// The object node.
    public let object: AnyRDFObject

    /// Creates a predicate and object pair.
    public init(predicate: IRI, object: AnyRDFObject) {
        self.predicate = predicate
        self.object = object
    }
}
