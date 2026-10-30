import Foundation

/// The base direction of a directional language-tagged string.
///
/// RDF 1.2 Concepts §3.4 Literals: "a base direction, which MUST be one of
/// `ltr` or `rtl`", the initial text direction of the literal's lexical form.
public enum BaseDirection: String, Hashable, Sendable, CaseIterable, Comparable, CustomStringConvertible {
    /// Left to right.
    case ltr

    /// Right to left.
    case rtl

    /// The direction as RDF writes it after `--`.
    public var description: String { rawValue }

    public static func < (lhs: BaseDirection, rhs: BaseDirection) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
