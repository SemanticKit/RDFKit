import RDFCore

// The values of the RDF, RDFS and OWL properties that RDFCore provides as
// DSL forms (`rdfs:label` is `RDFCore.Label`) and whose domain is
// `rdfs:Resource` or `rdf:Property`.
//
// A property whose domain is another ontology's class, or `rdfs:Resource`,
// is read through its term type: `@Ontology` generates `values(of:)` on that
// type. These terms' types are declared in RDFCore, which cannot name their
// ranges (`RDFS.Literal`, `RDF.Property`), and a macro cannot extend a type
// it is not attached to, so their accessors are written here. Each
// ontology's expansion checks its accessor against the declared domain and
// range, so a mismatch does not compile. `rdf:type` has none: an
// individual's classes are the protocols its type conforms to.

extension RDFCore.Label {
    /// The `rdfs:label` values of an individual: human-readable names.
    public static func values(of individual: some StoredIndividual) -> PropertyValues<RDFS.Literal> {
        propertyValues(of: individual)
    }
}

extension RDFCore.Comment {
    /// The `rdfs:comment` values of an individual: descriptions.
    public static func values(of individual: some StoredIndividual) -> PropertyValues<RDFS.Literal> {
        propertyValues(of: individual)
    }
}

extension RDFCore.SeeAlso {
    /// The `rdfs:seeAlso` values of an individual: resources with further
    /// information about it.
    public static func values(of individual: some StoredIndividual) -> PropertyValues<RDFS.Resource> {
        propertyValues(of: individual)
    }
}

extension RDFCore.Deprecated {
    /// The `owl:deprecated` values of an individual.
    public static func values(of individual: some StoredIndividual) -> PropertyValues<RDFS.Resource> {
        propertyValues(of: individual)
    }
}

// The generic DSL forms are one term each, whatever related type a
// declaration gives them, so their values are stored under one
// specialization, which `values(of:)` infers.

extension RDFCore.SubPropertyOf where Term == Never {
    /// The `rdfs:subPropertyOf` values of a property: its superproperties.
    public static func values(of property: some RDF.Property & StoredIndividual) -> PropertyValues<RDF.Property> {
        propertyValues(of: property)
    }
}

extension RDFCore.Domain where Term == Never {
    /// The `rdfs:domain` values of a property: the classes of its subjects.
    public static func values(of property: some RDF.Property & StoredIndividual) -> PropertyValues<RDFS.Class> {
        propertyValues(of: property)
    }
}

extension RDFCore.Range where Term == Never {
    /// The `rdfs:range` values of a property: the classes of its values.
    public static func values(of property: some RDF.Property & StoredIndividual) -> PropertyValues<RDFS.Class> {
        propertyValues(of: property)
    }
}
