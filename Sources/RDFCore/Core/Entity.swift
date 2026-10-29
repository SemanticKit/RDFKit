import IRIKit

/// An ontology entity declared in the DSL.
///
/// The Swift type is the entity's identity inside the runtime. Types refer to
/// each other as types, never through an IRI or a string. The entity's IRI
/// lives only in ``metadata``, a static projection that the `@Ontology` macro
/// computes from the ontology's namespace and that is read only at the
/// boundary (serialization, translation into SPARQL or SHACL, dereferencing).
public protocol Entity: Node, ContentElement {
    /// The boundary projection of this entity: its IRI and documentation.
    static var metadata: any ContentMetadata { get }
}

extension Entity {
    /// The values of this property of an individual, for a property whose
    /// domain is a class of another ontology.
    ///
    /// Such a property is no requirement of its domain's protocol, which
    /// another ontology declares, so its term type reads and changes its
    /// values: the `@Ontology` macro gives the term type a typed
    /// `values(of:)` that calls this, as in
    /// `OWL.equivalentClass.values(of: feline)`. The values are stored in the
    /// individual's ``Membership`` under the term type, so the member the
    /// ontology's extension point gives the individual (`feline.equivalentClass`)
    /// reads the same values.
    public static func propertyValues<Value: Sendable>(of individual: some StoredIndividual) -> PropertyValues<Value> {
        propertyValues(in: individual.membership)
    }

    /// The value of this functional property of an individual, for a
    /// property whose domain is a class of another ontology. See
    /// ``propertyValues(of:)``.
    public static func propertyValue<Value: Sendable>(of individual: some StoredIndividual) -> PropertyValue<Value> {
        propertyValue(in: individual.membership)
    }

    /// The values of this property stored in a membership under the term
    /// type: what an ontology's extension point member reads.
    public static func propertyValues<Value: Sendable>(in membership: Membership) -> PropertyValues<Value> {
        PropertyValues(term: self, of: membership)
    }

    /// The value of this functional property stored in a membership under
    /// the term type. See ``propertyValues(in:)``.
    public static func propertyValue<Value: Sendable>(in membership: Membership) -> PropertyValue<Value> {
        PropertyValue(term: self, of: membership)
    }
}
