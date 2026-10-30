/// The literals stated for one property of one individual that are not
/// values of the Swift type of the property's values: ill-typed literals
/// (RDF 1.2 Concepts §3.4), literals of another datatype, and literals not
/// in their datatype's canonical form, for a property whose range is a
/// datatype with a Swift value type (``DatatypeValue``).
///
/// They stay what RDF says they are, literals, and the individual's
/// ``IndividualStorage`` keeps them beside the property's values and writes
/// them back as they are, keyed by the property, so a document with them
/// decodes, and translates, back to the same graph. The property's accessor
/// holds only its values: `edition` of `"02"^^xsd:positiveInteger` is
/// empty, and the literal is kept here.
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
