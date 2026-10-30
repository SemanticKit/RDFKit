/// The literals stated for one property of one individual that denote no
/// value of the Swift type of the property's values, for a property whose
/// range is a datatype with a Swift value type (``DatatypeValue``):
/// ill-typed literals (RDF 1.2 Concepts §3.4), literals of a datatype with no
/// Swift type, and literals whose value is outside the range's value space.
///
/// They stay what RDF says they are, literals, and the individual's
/// ``IndividualStorage`` keeps them beside the property's values and writes
/// them back as they are, keyed by the property, so a document with them
/// decodes, and translates, back to the same graph. The property's accessor
/// holds only its values: `edition` of `"two"^^xsd:positiveInteger` is
/// empty, and the literal is kept here, until Swift sets the property's
/// values anew.
public struct PropertyLiterals<Property: PropertyValue>: PropertyValue {
    /// The property's declared key.
    public static var key: TermKey { Property.key }

    /// The literals.
    public var value: [Literal] = []

    public init() {}

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: PropertyKey.self)
        try container.encode(value, for: PropertyKey(Self.key))
    }
}
