import RDFCore

/// The RDF Schema vocabulary (RDFS), as rdfs.ttl publishes it.
@Ontology
public struct RDFS: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/2000/01/rdf-schema#")

        Class("Resource") {
            Type(RDFS.Class)
            Label("Resource")
            Comment("The class resource, everything.")
        }

        Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Class")
            Comment("The class of classes.")
        }

        Class("Literal") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Literal")
            Comment("The class of literal values, eg. textual strings and integers.")
        }

        Class("Datatype") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Class)
            Label("Datatype")
            Comment("The class of RDF datatypes.")
        }

        Class("Container") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Container")
            Comment("The class of RDF containers.")
        }

        Property("label") {
            Type(RDF.Property)
            Domain(RDFS.Resource)
            Range(RDFS.Literal)
            Label("label")
            Comment("A human-readable name for the subject.")
        }
    }
}
