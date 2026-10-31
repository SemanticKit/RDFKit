import RDFCore

/// The OWL 2 Schema vocabulary (OWL 2), as owl.ttl publishes it.
@Ontology
public struct OWL: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        RDFCore.Class("Class") {
            Type(RDFS.Class.self)
            SubClassOf(RDFS.Class.self)
            Label("Class")
            Comment("The class of OWL classes.")
        }
    }
}
