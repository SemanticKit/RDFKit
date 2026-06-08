import Foundation

/// An RDF blank node identified by a document-local label.
public struct BlankNode: Subject, Object, RawRepresentable, Equatable, Hashable, Sendable, Codable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The blank node label without the `_:` prefix.
    public let identifier: String

    /// Creates a blank node.
    public init(_ identifier: String) throws {
        guard !identifier.isEmpty else {
            throw RDFTermError.emptyBlankNodeIdentifier
        }
        self.identifier = identifier
    }

    /// Creates a blank node from its raw value.
    public init(rawValue: String) {
        self.identifier = rawValue
    }

    /// The raw blank node label.
    public var rawValue: String { identifier }

    /// A stable textual representation.
    public var description: String { "_:\(identifier)" }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "BlankNode(\(identifier.debugDescription))" }

    public static func < (lhs: BlankNode, rhs: BlankNode) -> Bool {
        lhs.identifier < rhs.identifier
    }
}
