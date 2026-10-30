import IRIKit
import RDFCore

/// The coding key of a property's values: the IRI of the property.
///
/// A generated `encode(to:)` keys each member by its property's declaration,
/// `PropertyKey(FOAF.knows)`, so the IRI is read only here, at the boundary.
public struct PropertyKey: CodingKey, Sendable {
    public let stringValue: String

    /// The key of a property's values. A blank node is not a property (RDF
    /// 1.2 Concepts §3.1), so its key is not an IRI, and an RDF encoder
    /// reports it.
    public init(_ property: any Resource) {
        stringValue = property.iri?.rawValue ?? ""
    }

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int? { nil }

    public init?(intValue: Int) {
        nil
    }
}

extension KeyedEncodingContainer where Key == PropertyKey {
    /// Writes literal values of a property.
    public mutating func encode(_ values: [Literal], for property: any Resource) throws {
        for value in values { try encode(Value.literal(value), forKey: PropertyKey(property)) }
    }

    /// Writes individuals that are values of a property.
    public mutating func encode(_ values: [any Resource], for property: any Resource) throws {
        for value in values { try encode(Value.individual(value), forKey: PropertyKey(property)) }
    }

    /// Writes classes that are values of a property.
    public mutating func encode(_ values: [any Class.Type], for property: any Resource) throws {
        for value in values { try encode(Value.class(value), forKey: PropertyKey(property)) }
    }

    /// Writes values of a property.
    public mutating func encode(_ values: [Value], for property: any Resource) throws {
        for value in values { try encode(value, forKey: PropertyKey(property)) }
    }
}
