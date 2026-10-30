/// Something an encoder writes as RDF: the triples it states about one
/// resource.
///
/// An individual (``Resource``) describes itself through its property
/// values. A class's description is what its documents state about the
/// class (``ClassDescription``), and an ``Addition`` is what one module
/// states about a resource another module declares. A translated module
/// lists its descriptions as `ontology`, the way back to its documents:
///
///     let document = try NTriplesEncoder().encode(FOAF.ontology)
public protocol Description: Sendable, Encodable {}
