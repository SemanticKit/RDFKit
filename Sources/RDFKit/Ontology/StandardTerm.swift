import Foundation

/// A value-level standard vocabulary term.
public struct StandardTerm: Term, RDFSubject, RDFPredicate, RDFObject, RawRepresentable, Comparable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The namespace-qualified name.
    public let qualifiedName: QualifiedName

    /// Creates a standard term.
    public init(namespace: Namespace, localName: LocalName) {
        self.qualifiedName = QualifiedName(namespace: namespace, localName: localName)
    }

    /// Creates a standard term from an IRI string.
    public init(rawValue: String) {
        self.qualifiedName = QualifiedName(rawValue)
    }

    /// The full IRI string.
    public var rawValue: String { iri.rawValue }

    /// The term IRI.
    public var iri: IRI { qualifiedName.iri }

    /// A stable textual representation.
    public var description: String { iri.description }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "StandardTerm(\(iri.rawValue.debugDescription))" }

    public static func < (lhs: StandardTerm, rhs: StandardTerm) -> Bool {
        lhs.iri < rhs.iri
    }

    public static func == (lhs: StandardTerm, rhs: StandardTerm) -> Bool {
        lhs.iri == rhs.iri
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(iri)
    }
}
