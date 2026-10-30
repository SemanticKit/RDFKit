/// The coding key of a property's values, derived from the property's
/// declared key.
///
/// A generated `encode(to:)` keys each value by its property:
/// `PropertyKey(FOAF.knows)` for a translated property, which is an
/// individual of `rdf:Property`, and `PropertyKey(Fauna.hasHabitat.key)`
/// for a property `@Ontology` declares. Its string value, the property's
/// IRI, is derived here, where the value leaves the runtime.
public struct PropertyKey: CodingKey, Sendable {
    public let stringValue: String

    /// The key of a property's values. A blank node is not a property (RDF
    /// 1.2 Concepts §3.1), so its key is not an IRI, and an RDF encoder
    /// reports it.
    public init(_ property: any Resource) {
        stringValue = Swift.type(of: property).key?.stringValue ?? ""
    }

    /// The key of the values of the property declared as `key`.
    public init(_ key: TermKey) {
        stringValue = key.stringValue
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
