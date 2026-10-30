/// The coding key of a property's values, derived from the property's
/// declared key.
///
/// A generated `encode(to:)` keys each value by its property's declared key,
/// which the property's term type carries: `PropertyKey(FOAF.knows.key)`
/// for a translated property, `PropertyKey(Fauna.hasHabitat.key)` for one
/// `@Ontology` declares. Its string value, the property's IRI, is derived
/// here, where the value leaves the runtime.
public struct PropertyKey: CodingKey, Sendable {
    public let stringValue: String

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

    /// Writes values of a datatype, which an encoder that writes RDF writes
    /// as literals.
    public mutating func encode<Member: DatatypeValue>(_ values: [Member], for property: PropertyKey) throws {
        for value in values { try encode(value, forKey: property) }
    }

    /// Writes properties that are values of a property, by their term types.
    public mutating func encode(_ values: [any PropertyTerm.Type], for property: PropertyKey) throws {
        for value in values { try encode(Value.property(value), forKey: property) }
    }

    /// Writes values of a property.
    public mutating func encode(_ values: [Value], for property: PropertyKey) throws {
        for value in values { try encode(value, forKey: property) }
    }
}
