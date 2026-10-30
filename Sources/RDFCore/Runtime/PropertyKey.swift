import IRIKit

/// The coding key of a property's values: the IRI of the property.
///
/// A generated `encode(to:)` keys each value by its property:
/// `PropertyKey(FOAF.knows)` for a translated property, which is an
/// individual of `rdf:Property`, and `PropertyKey(Fauna.hasHabitat.metadata)`
/// for a property `@Ontology` declares. The IRI is read only here, where the
/// value leaves the runtime.
public struct PropertyKey: CodingKey, Sendable {
    public let stringValue: String

    /// The key of a property's values. A blank node is not a property (RDF
    /// 1.2 Concepts §3.1), so its key is not an IRI, and an RDF encoder
    /// reports it.
    public init(_ property: any Resource) {
        stringValue = property.iri?.rawValue ?? ""
    }

    /// The key of the values of a property `@Ontology` declares, by the
    /// boundary projection of its term type.
    public init(_ metadata: any ContentMetadata) {
        stringValue = metadata.id.rawValue
    }

    /// The key of an individual's classes, `rdf:type`, which
    /// ``PropertyValueStoring`` writes for every individual. RDFCore is the
    /// runtime the translated `RDF` module is built on, so it names the
    /// property by its IRI here, at the coding key, where the value leaves
    /// the runtime.
    public static let type = PropertyKey(stringValue: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type")!

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
    public mutating func encode(_ values: [Literal], for property: PropertyKey) throws {
        for value in values { try encode(Value.literal(value), forKey: property) }
    }

    /// Writes individuals that are values of a property.
    public mutating func encode(_ values: [any Resource], for property: PropertyKey) throws {
        for value in values { try encode(Value.individual(value), forKey: property) }
    }

    /// Writes classes that are values of a property.
    public mutating func encode(_ values: [any ResourceClass.Type], for property: PropertyKey) throws {
        for value in values { try encode(Value.class(value), forKey: property) }
    }

    /// Writes values of a property.
    public mutating func encode(_ values: [Value], for property: PropertyKey) throws {
        for value in values { try encode(value, forKey: property) }
    }
}
