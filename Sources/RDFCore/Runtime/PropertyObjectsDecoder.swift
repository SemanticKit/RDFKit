/// The decoder an RDF format decoder gives for the objects of one property
/// of one subject (`superDecoder(forKey:)` of a container keyed by
/// ``PropertyKey``), which turns each object into the Swift value it
/// denotes.
///
/// It is the boundary of decoding: the objects are IRIs, blank nodes and
/// literals of the document, and what it returns are Swift values. An IRI or
/// blank node the document has already been decoded for is that individual;
/// one the document states is a member of a class the decoder may make is a
/// new member of it; any other is a new member of the class the property's
/// range gives.
public protocol PropertyObjectsDecoder: Decoder {
    /// The objects as literals.
    ///
    /// - Throws: `DecodingError.typeMismatch` for an object that is not a
    ///   literal.
    func literals() throws -> [Literal]

    /// The objects as individuals, each a member of `class` unless the
    /// document states it is a member of a class the decoder may make.
    ///
    /// - Throws: `DecodingError.typeMismatch` for a literal.
    func individuals(_ class: (any DecodableResource.Type)?) throws -> [any Resource]

    /// The objects as any value: a literal, a class or property the decoder
    /// knows, or an individual, a member of `resource` unless the document
    /// states otherwise.
    func values(_ resource: (any DecodableResource.Type)?) throws -> [Value]

    /// The objects as classes the decoder knows.
    ///
    /// - Throws: `DecodingError.dataCorrupted` for an object that names no
    ///   class the decoder knows.
    func classes() throws -> [any ResourceClass.Type]

    /// The objects as properties the decoder knows.
    ///
    /// - Throws: `DecodingError.dataCorrupted` for an object that names no
    ///   property the decoder knows.
    func properties() throws -> [any PropertyTerm.Type]
}

extension KeyedDecodingContainer where Key == PropertyKey {
    /// Reads literal values of a property.
    public func decode(_ type: [Literal].Type, for property: PropertyKey) throws -> [Literal] {
        try objects(property).literals()
    }

    /// Reads individuals that are values of a property, typed `Member`, the
    /// Swift type of the property's values. An object the document gives no
    /// class the decoder may make is a member of `class`.
    ///
    /// - Throws: `DecodingError.typeMismatch` for a value that is not a
    ///   `Member`.
    public func decode<Member>(_ type: [Member].Type, for property: PropertyKey, as class: (any DecodableResource.Type)?) throws -> [Member] {
        try objects(property).individuals(`class`).map { individual in
            guard let member = individual as? Member else {
                throw DecodingError.typeMismatch(Member.self, DecodingError.Context(
                    codingPath: codingPath + [property],
                    debugDescription: "The value is not a member of the property's range."
                ))
            }
            return member
        }
    }

    /// Reads classes that are values of a property.
    public func decode(_ type: [any ResourceClass.Type].Type, for property: PropertyKey) throws -> [any ResourceClass.Type] {
        try objects(property).classes()
    }

    /// Reads properties that are values of a property, as their term types.
    public func decode(_ type: [any PropertyTerm.Type].Type, for property: PropertyKey) throws -> [any PropertyTerm.Type] {
        try objects(property).properties()
    }

    /// Reads values of a property whose range admits any resource. An
    /// individual the document gives no class the decoder may make is a
    /// member of `resource`.
    public func decode(_ type: [Value].Type, for property: PropertyKey, as resource: (any DecodableResource.Type)?) throws -> [Value] {
        try objects(property).values(resource)
    }

    private func objects(_ property: PropertyKey) throws -> any PropertyObjectsDecoder {
        guard let decoder = try superDecoder(forKey: property) as? any PropertyObjectsDecoder else {
            throw DecodingError.typeMismatch(Value.self, DecodingError.Context(
                codingPath: codingPath + [property],
                debugDescription: "The values of a property are decoded from RDF, by an RDF decoder."
            ))
        }
        return decoder
    }
}
