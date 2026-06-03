import Foundation

/// An RDF namespace IRI used to qualify local vocabulary names.
public struct Namespace: RawRepresentable, Equatable, Hashable, Sendable, Codable, Comparable, LosslessStringConvertible, CustomStringConvertible, CustomDebugStringConvertible, IRIRepresentable, AliasTarget {
    /// The namespace IRI text.
    public let rawValue: String

    /// Creates a namespace from text.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a namespace from its raw value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The namespace as an RDF resource IRI.
    public var iri: IRI { IRI(rawValue) }

    /// A stable textual representation.
    public var description: String { rawValue }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "Namespace(\(rawValue.debugDescription))" }

    /// Returns this namespace as an alias target.
    public func aliasNamespace() throws -> Namespace { self }

    public static func < (lhs: Namespace, rhs: Namespace) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
