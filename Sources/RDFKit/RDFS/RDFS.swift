import Foundation
import RDFCore

/// The RDF Schema ontology.
public struct RDFS: Ontology {
    public var content: Content {
        Prefix.rdf
        Prefix.rdfs
        Prefix.owl
        Prefix.dc

        Namespace("http://www.w3.org/2000/01/rdf-schema#")

        Class("Class") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Class")
            Comment("The class of classes.")
        }

        Class("Resource") {
            Type(RDFSTerm.Class)
            Label("Resource")
            Comment("The class resource, everything.")
        }
        Class("Proposition") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Proposition")
            Comment(
                "The class of propositions, simple logical expressions describing a relationship between two entities."
            )
        }
        Property("subClassOf") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Class)
            Range(RDFSTerm.Class)
            Label("subClassOf")
            Comment("The subject is a subclass of a class.")
        }
        Property("subPropertyOf") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Property)
            Range(RDFTerm.Property)
            Label("subPropertyOf")
            Comment("The subject is a subproperty of a property.")
        }
        Property("comment") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Literal)
            Label("comment")
            Comment("A description of the subject resource.")
        }
        Property("label") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Literal)
            Label("label")
            Comment("A human-readable name for the subject.")
        }
        Property("domain") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Property)
            Range(RDFSTerm.Class)
            Label("domain")
            Comment("A domain of the subject property.")
        }
        Property("range") {
            Type(RDFTerm.Property)
            Domain(RDFTerm.Property)
            Range(RDFSTerm.Class)
            Label("range")
            Comment("A range of the subject property.")
        }
        Property("seeAlso") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("seeAlso")
            Comment("Further information about the subject resource.")
        }
        Property("isDefinedBy") {
            Type(RDFTerm.Property)
            SubPropertyOf(RDFSTerm.SeeAlso)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("isDefinedBy")
            Comment("The definition of the subject resource.")
        }
        Class("Literal") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Literal")
            Comment(
                "The class of literal values, eg. textual strings and integers."
            )
        }
        Class("Container") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Resource)
            Label("Container")
            Comment("The class of RDF containers.")
        }
        Class("ContainerMembershipProperty") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFTerm.Property)
            Label("ContainerMembershipProperty")
            Comment(
                "The class of container membership properties, rdf:_1, rdf:_2, ..., all of which are sub-properties of 'member'."
            )
        }
        Property("member") {
            Type(RDFTerm.Property)
            Domain(RDFSTerm.Resource)
            Range(RDFSTerm.Resource)
            Label("member")
            Comment("A member of the subject resource.")
        }
        Class("Datatype") {
            Type(RDFSTerm.Class)
            SubClassOf(RDFSTerm.Class)
            Label("Datatype")
            Comment("The class of RDF datatypes.")
        }
    }
}
