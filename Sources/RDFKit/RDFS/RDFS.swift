import Foundation
import RDFCore
import IRIKit

/// The RDF Schema ontology.
@Vocabulary
public struct RDFS: Ontology {
    public var content: Content {
        Prefix.rdf
        Prefix.rdfs
        Prefix.owl
        Prefix.dc

        Namespace("http://www.w3.org/2000/01/rdf-schema#")

        Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Class")
            Comment("The class of classes.")
        }

        Class("Resource") {
            Type(RDFS.Class)
            Label("Resource")
            Comment("The class resource, everything.")
        }
        Class("Proposition") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Proposition")
            Comment(
                "The class of propositions, simple logical expressions describing a relationship between two entities."
            )
        }
        Property("subClassOf") {
            Type(RDF.Property)
            Domain(RDFS.Class)
            Range(RDFS.Class)
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }
        Property("subPropertyOf") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDF.Property)
            Label("subPropertyOf")
            Comment("The subject is a subproperty of a property.")
        }
        Property("comment") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Literal)
            Label("comment")
            Comment("A description of the subject resource.")
        }
        Property("label") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Literal)
            Label("label")
            Comment("A human-readable name for the subject.")
        }
        Property("domain") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDFS.Class)
            Label("domain")
            Comment("A domain of the subject property.")
        }
        Property("range") {
            Type(RDF.Property)
            Domain(RDF.Property)
            Range(RDFS.Class)
            Label("range")
            Comment("A range of the subject property.")
        }
        Property("seeAlso") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("seeAlso")
            Comment("Further information about the subject resource.")
        }
        Property("isDefinedBy") {
            Type(RDF.Property)
            SubPropertyOf(RDFS.seeAlso)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }
        Class("Literal") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Literal")
            Comment(
                "The class of literal values, eg. textual strings and integers."
            )
        }
        Class("Container") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Container")
            Comment("The class of RDF containers.")
        }
        Class("ContainerMembershipProperty") {
            Type(RDFS.Class)
            SubClassOf(RDF.Property)
            Label("ContainerMembershipProperty")
            Comment(
                "The class of container membership properties, rdf:_1, rdf:_2, ..., all of which are sub-properties of 'member'."
            )
        }
        Property("member") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Resource)
            Label("member")
            Comment("A member of the subject resource.")
        }
        Class("Datatype") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Class)
            Label("Datatype")
            Comment("The class of RDF datatypes.")
        }
    }
}
