import Foundation

#if canImport(CoreTransferable)
import CoreTransferable
#endif

/// An RDF Internationalized Resource Identifier value.
public struct IRI: RawRepresentable, Equatable, Hashable, Sendable, Codable, Comparable, Identifiable, LosslessStringConvertible, CustomStringConvertible, CustomDebugStringConvertible, Subject, Predicate, Object, IRIRepresentable {
    /// The canonical IRI text used for equality and hashing.
    public let rawValue: String

    /// Creates an IRI from text.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates an IRI from its raw value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The stable identity for this IRI.
    public var id: IRI { self }

    /// The represented IRI.
    public var iri: IRI { self }

    /// The canonical IRI string.
    public var string: String { rawValue }

    /// The scheme component when present.
    public var scheme: String {
        guard let separator = rawValue.firstIndex(of: ":") else { return "" }
        return String(rawValue[..<separator]).lowercased()
    }

    /// A stable textual representation.
    public var description: String { rawValue }

    /// A debugging representation that includes the type name.
    public var debugDescription: String { "IRI(\(rawValue.debugDescription))" }

    /// Returns a Foundation URL for this IRI.
    public func asURL() throws -> URL {
        guard let url = URL(string: rawValue) else {
            throw RDFTermError.invalidIRI(rawValue)
        }
        return url
    }

    public static func < (lhs: IRI, rhs: IRI) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension URL: IRIRepresentable {
    /// The absolute string of this URL as an RDF IRI.
    public var iri: IRI { IRI(absoluteString) }
}

#if canImport(CoreTransferable)
extension IRI: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.rawValue)
    }
}
#endif
