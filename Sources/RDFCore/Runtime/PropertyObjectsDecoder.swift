/// The decoder an RDF format decoder gives for the objects of one property
/// of one subject (`superDecoder(forKey:)` of a container keyed by
/// ``PropertyKey``), which turns each object into the Swift value it
/// denotes.
///
/// It is the boundary of decoding: the objects are IRIs, blank nodes and
/// literals of the document, and what it returns are Swift values. A literal
/// is the literal; an IRI that names a class or property the decoder knows is
/// that class or property; a triple term is a ``Value/tripleTerm(subject:predicate:object:)``
/// of the values of its subject and object; an IRI or blank node the document has already been
/// decoded for is that individual; one the document states is a member of a
/// class the decoder may make is a new member of it; any other is a new
/// member of the class the property's range gives.
public protocol PropertyObjectsDecoder: Decoder {
    /// The objects as Swift values, a node the document gives no class the
    /// decoder may make being a new member of `class`.
    ///
    /// - Throws: `DecodingError` for an object that has no Swift value, such
    ///   as a node no class is given for.
    func values(_ class: (any DecodableResource.Type)?) throws -> [Value]
}

extension KeyedDecodingContainer where Key == PropertyKey {
    /// Reads the values of a property, typed `Member`, the Swift type of the
    /// property's values: a literal, an individual of the range's classes, a
    /// class, a property or any ``Value``. An object the document gives no
    /// class the decoder may make is a new member of `class`, the class of
    /// the property's range.
    ///
    /// - Throws: `DecodingError.typeMismatch` for a value that is not a
    ///   `Member`, and when the decoder is not an RDF decoder.
    public func decode<Member>(_ type: [Member].Type, for property: PropertyKey, as class: (any DecodableResource.Type)?) throws -> [Member] {
        guard let decoder = try superDecoder(forKey: property) as? any PropertyObjectsDecoder else {
            throw DecodingError.typeMismatch(Value.self, DecodingError.Context(
                codingPath: codingPath + [property],
                debugDescription: "The values of a property are decoded from RDF, by an RDF decoder."
            ))
        }
        return try decoder.values(`class`).map { value in
            guard let member = value.member(Member.self) else {
                throw DecodingError.typeMismatch(Member.self, DecodingError.Context(
                    codingPath: codingPath + [property],
                    debugDescription: "The value is not of the Swift type of the property's values."
                ))
            }
            return member
        }
    }
}

extension Value {
    /// The value as a `Member`: the value itself, or what its case holds.
    fileprivate func member<Member>(_ type: Member.Type) -> Member? {
        if let member = self as? Member { return member }
        return switch self {
        case .individual(let individual): individual as? Member
        case .class(let type): type as? Member
        case .property(let term): term as? Member
        case .literal(let literal): literal as? Member
        case .tripleTerm: nil
        }
    }
}
