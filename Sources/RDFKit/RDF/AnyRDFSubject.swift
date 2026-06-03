import Foundation

/// A type-erased RDF subject.
public struct AnyRDFSubject: RDFSubject {
    /// The erased subject node.
    public let node: any RDFSubject

    /// Creates a type-erased subject.
    public init(_ node: any RDFSubject) throws {
        if let iriRepresentable = node as? any IRIRepresentable {
            self.node = iriRepresentable.iri
        } else {
            self.node = node
        }
    }

    /// Creates a type-erased subject from an IRI.
    public init(_ iri: IRI) {
        self.node = iri
    }

    /// Creates a type-erased subject from a blank node.
    public init(_ blankNode: BlankNode) {
        self.node = blankNode
    }

    /// A stable textual representation.
    public var description: String { node.description }

    public static func == (lhs: AnyRDFSubject, rhs: AnyRDFSubject) -> Bool {
        AnyHashable(lhs.node) == AnyHashable(rhs.node)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(AnyHashable(node))
    }
}
