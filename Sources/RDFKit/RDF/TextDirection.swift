import Foundation

/// RDF text direction for directional language-tagged strings.
public enum TextDirection: String, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    /// Left-to-right text direction.
    case ltr

    /// Right-to-left text direction.
    case rtl

    /// A stable textual representation.
    public var description: String { rawValue }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "TextDirection.\(rawValue)" }

    public static func < (lhs: TextDirection, rhs: TextDirection) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
