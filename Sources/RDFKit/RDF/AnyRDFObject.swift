import Foundation

/// A type-erased RDF object.
public struct AnyRDFObject: RDFObject {
    /// The erased object node.
    public let node: any RDFObject

    /// Creates a type-erased object.
    public init(_ node: any RDFObject) {
        if let iriRepresentable = node as? any IRIRepresentable {
            self.node = iriRepresentable.iri
        } else {
            self.node = node
        }
    }

    /// Creates a type-erased object from an IRI.
    public init(_ iri: IRI) {
        self.node = iri
    }

    /// Creates a type-erased object from a blank node.
    public init(_ blankNode: BlankNode) {
        self.node = blankNode
    }

    /// A stable textual representation.
    public var description: String { node.description }

    public static func == (lhs: AnyRDFObject, rhs: AnyRDFObject) -> Bool {
        AnyHashable(lhs.node) == AnyHashable(rhs.node)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(AnyHashable(node))
    }
}
