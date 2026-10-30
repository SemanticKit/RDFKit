/// An individual's Swift class whose instances a decoder makes from a
/// document: `FOAF.PersonIndividual`, which `RDFTranslatorPlugin` generates
/// for `foaf:Person`.
///
/// Decoding is in two steps, so that individuals can refer to each other,
/// cycles included (`:alice foaf:knows :bob . :bob foaf:knows :alice .`): the
/// decoder makes the individual with ``init()``, keeps it for its node of the
/// document, and then reads its values with ``decodeValues(from:)``. The
/// individual holds no IRI: the correspondence between the document's IRIs
/// and the individuals decoded from it belongs to the decoder's context, as
/// `Decoder.codingPath` belongs to a `Decoder`, never to the value.
public protocol DecodableResource: PropertyValueStoring {
    /// An individual with no values, which a decoder fills.
    init()

    /// The properties a member of the class has: the value types its
    /// accessors keep in its ``IndividualStorage``, which a decoder reads.
    static var properties: [any (PropertyValue & Decodable).Type] { get }
}

extension DecodableResource {
    /// Reads every property value the decoder states for the individual,
    /// keyed by ``PropertyKey``. The classes the individual is a member of
    /// are its Swift class's ``PropertyValueStoring/classes``, so the
    /// property they are written with is not read as a value.
    public func decodeValues(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PropertyKey.self)
        for property in Self.properties where property.key != Self.typeProperty {
            guard container.contains(PropertyKey(property.key)) else { continue }
            try storage.decode(property, from: decoder)
        }
    }
}
