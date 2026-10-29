import IRIKit
import RDFCore

/// A resource an RDF document describes, as the Swift object the
/// `RDFTranslatorPlugin` built it into.
///
/// RDF 1.2 Concepts §1.2: "Any IRI or literal denotes something in the world
/// (the 'universe of discourse'). These things are called resources." The
/// plugin turns every IRI and blank node of a document into one object, whose
/// class conforms to the protocols generated for the resource's classes, so
/// `rdf:type` and `rdfs:subClassOf` hold as Swift membership:
///
///     alice is Person   // :alice a foaf:Person
///     alice is Agent    // foaf:Person rdfs:subClassOf foaf:Agent
///
/// The object is the resource inside the runtime. Its IRI is read only where
/// it leaves the runtime, when an encoder writes it as a document.
public protocol Resource: AnyObject, Sendable, Encodable {
    /// The IRI that denotes the resource, or `nil` for a blank node.
    ///
    /// Every generated resource has a class of its own, so the IRI belongs to
    /// the type: the type is the resource's identity.
    static var iri: IRI? { get }

    /// The values of the resource's properties: the triples the document
    /// states with the resource as subject.
    var propertyValues: PropertyValues { get }
}

extension Resource {
    /// Writes the resource's property values to a keyed container, one
    /// entry for each value, keyed by the IRI of its property.
    ///
    /// A value is a ``Resource`` or an RDF ``Literal``. An encoder that writes
    /// RDF writes a resource in object position as its IRI or blank node.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: PropertyKey.self)
        for (property, value) in propertyValues.all {
            guard let iri = type(of: property).iri else {
                throw EncodingError.invalidValue(value, EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "A property is an IRI (RDF 1.2 Concepts §3.1); this one is a blank node."
                ))
            }
            try container.encode(value, forKey: PropertyKey(iri))
        }
    }
}

/// The coding key of a property value: the IRI of the property.
struct PropertyKey: CodingKey {
    let stringValue: String

    init(_ iri: IRI) {
        stringValue = iri.rawValue
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int? { nil }

    init?(intValue: Int) {
        nil
    }
}
