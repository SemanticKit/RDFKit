import RDFCore

/// The RDF Concepts vocabulary (RDF), as rdf.ttl publishes it.
@Ontology
public struct RDF: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

        Class("Property") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Property")
            Comment("The class of RDF properties.")
        }

        Class("List") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("List")
            Comment("The class of RDF Lists.")
        }

        Class("Statement") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Statement")
            Comment("The class of RDF statements.")
        }

        Class("CompoundLiteral") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("CompoundLiteral")
            Comment("A class representing a compound literal.")
        }

        Property("first") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDFS.Resource)
            Label("first")
            Comment("The first item in the subject RDF list.")
        }

        Property("rest") {
            Type(RDF.Property)
            Domain(RDF.List)
            Range(RDF.List)
            Label("rest")
            Comment("The rest of the subject RDF list after the first item.")
        }
    }
}
