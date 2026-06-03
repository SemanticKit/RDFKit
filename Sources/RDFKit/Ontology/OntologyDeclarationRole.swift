import Foundation

/// The role a declaration plays inside an ontology.
public enum OntologyDeclarationRole: String, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// A class declaration.
    case `class`

    /// A property declaration.
    case property

    /// A datatype declaration.
    case datatype

    /// An individual declaration.
    case individual

    /// A stable textual representation.
    public var description: String { rawValue }

    public static func < (lhs: OntologyDeclarationRole, rhs: OntologyDeclarationRole) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
