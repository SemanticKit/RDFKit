import Foundation
import IRIKit

/// A namespace IRI used to qualify vocabulary terms.


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
