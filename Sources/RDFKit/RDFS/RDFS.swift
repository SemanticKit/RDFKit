import RDFCore

/// The RDF Schema vocabulary (RDFS), as rdfs.ttl publishes it.
@Ontology
public struct RDFS: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/2000/01/rdf-schema#")

        RDFCore.Class("Resource") {
            Type(RDFS.Class.self)
            Label("Resource")
            Comment("The class resource, everything.")
        }

        RDFCore.Class("Class") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Resource.self)
            Label("Class")
            Comment("The class of classes.")
        }
    }
}
