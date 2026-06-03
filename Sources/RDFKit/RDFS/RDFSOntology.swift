import Foundation

public extension RDFS {
    /// The RDFS vocabulary expressed as Turtle-like Swift ontology DSL content.
    static var ontology: some Content {
        RDFSOntology().content
    }
}

/// RDFS vocabulary content authored in the ontology declaration DSL.
private struct RDFSOntology: Ontology {
    var content: some Content {
        Namespace("http://www.w3.org/2000/01/rdf-schema#")
        Alias("rdf", RDF.self)
        Alias("rdfs", RDFS.self)
        Alias("owl", OWL.self)

        Class("Resource") {
            Type(RDFS.Class.self)
            IsDefinedBy(RDFS())
            Label("Resource")
            Comment("The class resource, everything.")
        }
        Class("Proposition") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("Proposition")
            Comment("The class of propositions, simple logical expressions describing a relationship between two entities.")
        }
        Class("Class") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("Class")
            Comment("The class of classes.")
        }
        Property("subClassOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDFS.Class.self)
            IsDefinedBy(RDFS())
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }
        Property("subPropertyOf") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDF.Property.self)
            IsDefinedBy(RDFS())
            Label("subPropertyOf")
            Comment("The subject is a subproperty of a property.")
        }
        Property("comment") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Literal.self)
            IsDefinedBy(RDFS())
            Label("comment")
            Comment("A description of the subject resource.")
        }
        Property("label") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Literal.self)
            IsDefinedBy(RDFS())
            Label("label")
            Comment("A human-readable name for the subject.")
        }
        Property("domain") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDFS.Class.self)
            IsDefinedBy(RDFS())
            Label("domain")
            Comment("A domain of the subject property.")
        }
        Property("range") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDFS.Class.self)
            IsDefinedBy(RDFS())
            Label("range")
            Comment("A range of the subject property.")
        }
        Property("seeAlso") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("seeAlso")
            Comment("Further information about the subject resource.")
        }
        Property("isDefinedBy") {
            Type(RDF.Property.self)
            SubPropertyOf(RDFS.SeeAlso.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }
        Class("Literal") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("Literal")
            Comment("The class of literal values, eg. textual strings and integers.")
        }
        Class("Container") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("Container")
            Comment("The class of RDF containers.")
        }
        Class("ContainerMembershipProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy(RDFS())
            Label("ContainerMembershipProperty")
            Comment("The class of container membership properties, rdf:_1, rdf:_2, ..., all of which are sub-properties of 'member'.")
        }
        Property("member") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy(RDFS())
            Label("member")
            Comment("A member of the subject resource.")
        }
        Class("Datatype") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Class.self)
            IsDefinedBy(RDFS())
            Label("Datatype")
            Comment("The class of RDF datatypes.")
        }
    }
}
