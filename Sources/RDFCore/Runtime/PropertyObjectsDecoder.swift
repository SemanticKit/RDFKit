/// The decoder an RDF format decoder gives for the objects of one property
/// of one subject (`superDecoder(forKey:)` of a container keyed by
/// ``PropertyKey``), which turns each object into the Swift value it
/// denotes.
///
/// It is the boundary of decoding: the objects are IRIs, blank nodes and
/// literals of the document, and what it returns are Swift values. A literal
/// is the literal; an IRI that names a class or property the decoder knows is
/// that class or property; an IRI or blank node the document has already been
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

    /// Keeps literals that are not values of the Swift type of the
    /// property's values, a datatype's value type: they stay literals, at
    /// the boundary, and the individual writes them back as they are
    /// (``PropertyLiterals``).
    func keep(_ literals: [Literal])

    /// The literals kept for this property of this subject.
    var keptLiterals: [Literal] { get }
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
        // A literal of a property typed by a datatype's value type is the
        // value it denotes, or, when it is not one, kept as it is.
        let datatype = Member.self as? any DatatypeValue.Type
        var members: [Member] = []
        var kept: [Literal] = []
        for value in try decoder.values(`class`) {
            if let datatype, case .literal(let literal) = value {
                if let member = datatype.init(holding: literal) as? Member {
                    members.append(member)
                } else {
                    kept.append(literal)
                }
                continue
            }
            guard let member = value.member(Member.self) else {
                throw DecodingError.typeMismatch(Member.self, DecodingError.Context(
                    codingPath: codingPath + [property],
                    debugDescription: "The value is not of the Swift type of the property's values."
                ))
            }
            members.append(member)
        }
        if !kept.isEmpty { decoder.keep(kept) }
        return members
    }
}

extension KeyedDecodingContainer where Key == PropertyKey {
    /// Reads the values of a property whose range is a datatype with a
    /// Swift value type, typed `Member`: the values of the literals that
    /// type holds. The other literals are kept as they are
    /// (``PropertyLiterals``). `datatype` is the class that stands for the
    /// datatype, whose members are values, never individuals a decoder
    /// makes.
    ///
    /// - Throws: `DecodingError.typeMismatch` for an object that is not a
    ///   literal, and when the decoder is not an RDF decoder.
    public func decode<Member: DatatypeValue>(_ type: [Member].Type, for property: PropertyKey, as datatype: (any ResourceClass.Type)?) throws -> [Member] {
        let noClass: (any DecodableResource.Type)? = nil
        return try decode(type, for: property, as: noClass)
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
        }
    }
}
