import Foundation

/// RDF literal base text direction.
public enum TextDirection: String, Sendable, Codable, CaseIterable, Comparable, CustomStringConvertible {
    case ltr
    case rtl

    /// A stable textual representation.
    public var description: String { rawValue }

    public static func < (lhs: TextDirection, rhs: TextDirection) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
