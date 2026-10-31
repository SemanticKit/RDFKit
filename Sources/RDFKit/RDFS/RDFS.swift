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
    }
}
