import IRIKit

/// An ontology entity declared in the DSL.
///
/// The Swift type is the entity's identity inside the runtime. Types refer to
/// each other as types, never through an IRI or a string. The entity's IRI
/// lives only in ``metadata``, a static projection that the `@Ontology` macro
/// computes from the ontology's namespace and that is read only at the
/// boundary (serialization, translation into SPARQL or SHACL, dereferencing).
public protocol Entity: Node {
    /// The boundary projection of this entity: its IRI and documentation.
    static var metadata: any ContentMetadata { get }
}

extension Entity {
    /// The values of this property of an individual, for a property whose
    /// domain is a class of another ontology, or `rdfs:Resource`.
    ///
    /// Such a property is no requirement of its domain's protocol, which
    /// another ontology declares, so its term type reads and changes its
    /// values: the `@Ontology` macro gives the term type a typed
    /// `values(of:)` that calls this, as in
    /// `OWL.equivalentClass.values(of: feline)`. The values are stored in the
    /// individual's ``Membership`` under the term type.
    public static func propertyValues<Value: Sendable>(of individual: some StoredIndividual) -> PropertyValues<Value> {
        PropertyValues(term: self, of: individual.membership)
    }

    /// The value of this functional property of an individual, for a
    /// property whose domain is a class of another ontology, or
    /// `rdfs:Resource`. See ``propertyValues(of:)``.
    public static func propertyValue<Value: Sendable>(of individual: some StoredIndividual) -> PropertyValue<Value> {
        PropertyValue(term: self, of: individual.membership)
    }
}
