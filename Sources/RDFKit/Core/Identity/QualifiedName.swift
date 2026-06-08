import Foundation

/// A namespace-qualified vocabulary name.
public struct QualifiedName: Equatable, Hashable, Sendable, Codable, Comparable, LosslessStringConvertible, CustomStringConvertible, CustomDebugStringConvertible, IRIRepresentable {
    /// The namespace part of the name.
    public let namespace: Namespace

    /// The local part of the name.
    public let localName: LocalName

    /// Creates a qualified name.
    public init(namespace: Namespace, localName: LocalName) {
        self.namespace = namespace
        self.localName = localName
    }

    /// Creates a qualified name from a full IRI string.
    public init(_ description: String) {
        let split = QualifiedName.split(description)
        self.namespace = Namespace(split.namespace)
        self.localName = LocalName(split.localName)
    }

    /// The full RDF resource IRI.
    public var iri: IRI { IRI(namespace.rawValue + localName.rawValue) }

    /// The full IRI string.
    public var description: String { iri.rawValue }

    /// A debugging representation that includes the type name.
    public var debugDescription: String {
        "QualifiedName(namespace: \(namespace.debugDescription), localName: \(localName.debugDescription))"
    }

    public static func < (lhs: QualifiedName, rhs: QualifiedName) -> Bool {
        lhs.description < rhs.description
    }

    private static func split(_ value: String) -> (namespace: String, localName: String) {
        let separatorIndex = value.lastIndex(of: "#") ?? value.lastIndex(of: "/")
        guard let separatorIndex else {
            return ("", value)
        }
        let localStart = value.index(after: separatorIndex)
        return (String(value[...separatorIndex]), String(value[localStart...]))
    }
}
