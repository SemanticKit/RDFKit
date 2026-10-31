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
    }
}
