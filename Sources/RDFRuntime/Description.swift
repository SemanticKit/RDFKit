/// Triples a module's documents state about one resource, which an encoder
/// writes as a document.
///
/// Each translated module lists its descriptions as `ontology`, the way back
/// to the documents' graph:
///
///     let document = try NTriplesEncoder().encode(FOAF.ontology)
///
/// A description is an individual (a ``Resource``), the description of a
/// class (``ClassDescription``), or what one module states about a
/// resource another module declares (``Addition``).
public protocol Description: Sendable, Encodable {}

/// The description of a class: the triples its document states about it.
public struct ClassDescription: Description {
    /// The class.
    public let `class`: any Class.Type

    /// The description of a class.
    public init(_ class: any Class.Type) {
        self.class = `class`
    }

    public func encode(to encoder: any Encoder) throws {
        try `class`.encodeDescription(to: encoder)
    }
}

/// What a module's documents state about a resource that a module it builds
/// on declares, such as FOAF's `owl:Thing rdfs:label "Thing"`.
///
/// The resource keeps its one declaration; the addition refers to it.
public protocol Addition: Description {
    /// The resource the triples are about.
    var resource: Value { get }
}
