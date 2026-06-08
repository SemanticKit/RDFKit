import Foundation

public extension RDFS {
    /// The RDFS standard ontology authored as Swift content.
    static var ontology: some Content {
        RDFSOntology().content
    }
}

/// RDFS standard ontology content authored with ontology declarations.
private struct RDFSOntology: Ontology {
    var content: some Content {
        Namespace("http://www.w3.org/2000/01/rdf-schema#")
        Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
        Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))

        Class("Resource") {
            Type(RDFS.Class.self)
            IsDefinedBy()
            Label("Resource")
            Comment("The class resource, everything.")
        }
        Class("Proposition") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Proposition")
            Comment("The class of propositions, simple logical expressions describing a relationship between two entities.")
        }
        Class("Class") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Class")
            Comment("The class of classes.")
        }
        Property("subClassOf") {
            Type(RDF.Property.self)
            Domain(RDFS.Class.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }
        Property("subPropertyOf") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDF.Property.self)
            IsDefinedBy()
            Label("subPropertyOf")
            Comment("The subject is a subproperty of a property.")
        }
        Property("comment") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Literal.self)
            IsDefinedBy()
            Label("comment")
            Comment("A description of the subject resource.")
        }
        Property("label") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Literal.self)
            IsDefinedBy()
            Label("label")
            Comment("A human-readable name for the subject.")
        }
        Property("domain") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("domain")
            Comment("A domain of the subject property.")
        }
        Property("range") {
            Type(RDF.Property.self)
            Domain(RDF.Property.self)
            Range(RDFS.Class.self)
            IsDefinedBy()
            Label("range")
            Comment("A range of the subject property.")
        }
        Property("seeAlso") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("seeAlso")
            Comment("Further information about the subject resource.")
        }
        Property("isDefinedBy") {
            Type(RDF.Property.self)
            SubPropertyOf(RDFS.SeeAlso.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }
        Class("Literal") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Literal")
            Comment("The class of literal values, eg. textual strings and integers.")
        }
        Class("Container") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            IsDefinedBy()
            Label("Container")
            Comment("The class of RDF containers.")
        }
        Class("ContainerMembershipProperty") {
            Type(RDFS.Class.self)
            SubClassOf(RDF.Property.self)
            IsDefinedBy()
            Label("ContainerMembershipProperty")
            Comment("The class of container membership properties, rdf:_1, rdf:_2, ..., all of which are sub-properties of 'member'.")
        }
        Property("member") {
            Type(RDF.Property.self)
            Domain(RDFS.Resource.self)
            Range(RDFS.Resource.self)
            IsDefinedBy()
            Label("member")
            Comment("A member of the subject resource.")
        }
        Class("Datatype") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Class.self)
            IsDefinedBy()
            Label("Datatype")
            Comment("The class of RDF datatypes.")
        }
    }
}
