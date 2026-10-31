import RDFCore

/// The OWL 2 Schema vocabulary (OWL 2), as owl.ttl publishes it.
@Ontology
public struct OWL: Ontology {
    public var body: some Content {
        Namespace("http://www.w3.org/2002/07/owl#")

        Class("Class") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Class)
            Label("Class")
            Comment("The class of OWL classes.")
        }

        Class("Thing") {
            Type(OWL.Class)
            Label("Thing")
            Comment("The class of OWL individuals.")
        }

        Class("Ontology") {
            Type(RDFS.Class)
            SubClassOf(RDFS.Resource)
            Label("Ontology")
            Comment("The class of ontologies.")
        }
    }
}
