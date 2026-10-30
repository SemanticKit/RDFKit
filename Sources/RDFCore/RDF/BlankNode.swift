import Foundation

/// An RDF blank node.
///
/// RDF 1.2 Concepts §3.5 Blank Nodes: "Blank nodes are disjoint from IRIs and
/// literals. Otherwise, the set of possible blank nodes is arbitrary." The
/// identifier is the document-local label a format writes after `_:`; two
/// blank nodes are the same node when their identifiers are equal, Unicode
/// scalar by Unicode scalar, never by Swift `String`'s canonical equivalence,
/// so that a graph keeps `_:\u{E9}` and `_:e\u{301}` apart as IRIKit's `IRI`
/// keeps its characters apart.
public struct BlankNode: Subject, Object, Hashable, Sendable, Comparable, CustomStringConvertible {
    /// The blank node identifier, without the `_:` prefix.
    public let identifier: String

    /// Creates a blank node.
    ///
    /// - Throws: ``TermError/emptyBlankNodeIdentifier`` when the identifier
    ///   is empty.
    public init(_ identifier: String) throws(TermError) {
        guard !identifier.isEmpty else { throw .emptyBlankNodeIdentifier }
        self.identifier = identifier
    }

    /// The blank node as N-Triples writes it.
    public var description: String { "_:\(identifier)" }

    public static func == (lhs: BlankNode, rhs: BlankNode) -> Bool {
        lhs.identifier.unicodeScalars.elementsEqual(rhs.identifier.unicodeScalars)
    }

    public func hash(into hasher: inout Hasher) {
        for scalar in identifier.unicodeScalars {
            hasher.combine(scalar.value)
        }
    }

    public static func < (lhs: BlankNode, rhs: BlankNode) -> Bool {
        lhs.identifier.unicodeScalars.lexicographicallyPrecedes(rhs.identifier.unicodeScalars)
    }
}
