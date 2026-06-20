import Foundation
import IRIKit

/// A namespace IRI used to qualify vocabulary terms.
public struct Namespace: Entity {
    public typealias ID = IRI
    public typealias Metadata = RDFMetadata

    public static let metadata = RDFMetadata(
        id: "http://semantickit.io/o/2026/06/rdfkit#Namespace",
        name: "Namespace",
        type: "RDFKit.Namespace",
        label: "Namespace",
        comment: "The namespace of the Ontology."
    )

    public let id: ID

    /// The target namespace.
    public let namespace: String

    /// Creates a prefix alias.
    public init(_ namespace: String) {
        guard let id = try? ID(validating: namespace) else {
            preconditionFailure(
                "Could not validate the provided namespace identity as an IRI from \(namespace)."
            )
        }

        self.id = id
        self.namespace = namespace
    }
}

//public struct Namespace: Node, RawRepresentable, Equatable, Hashable, Sendable, Codable, Comparable, LosslessStringConvertible, CustomStringConvertible, ExpressibleByStringLiteral {
//
//    /// The namespace IRI text.
//    public let rawValue: String
//
//    /// Creates a namespace from text.
//    public init(_ rawValue: String) {
//        self.rawValue = rawValue
//    }
//
//    /// Creates a namespace from its raw value.
//    public init(rawValue: String) {
//        self.rawValue = rawValue
//    }
//
//    /// Creates a namespace from a string literal.
//    public init(stringLiteral value: String) {
//        self.rawValue = value
//    }
//
//    /// The namespace as an RDF resource IRI.
//    public var iri: IRI { try! IRI(validating: rawValue) }
//
//    /// A stable textual representation.
//    public var description: String { rawValue }
//
//    public static func < (lhs: Namespace, rhs: Namespace) -> Bool {
//        lhs.rawValue < rhs.rawValue
//    }
//}
