import Foundation

/// The local part of a vocabulary-qualified RDF name.
public struct LocalName: RawRepresentable, Equatable, Hashable, Sendable, Codable, Comparable, ExpressibleByStringLiteral, LosslessStringConvertible, CustomStringConvertible, CustomDebugStringConvertible {
    /// The local-name text.
    public let rawValue: String

    /// Creates a local name.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a local name from its raw value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a local name from a string literal.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// A stable textual representation.
    public var description: String { rawValue }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "LocalName(\(rawValue.debugDescription))" }

    public static func < (lhs: LocalName, rhs: LocalName) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
