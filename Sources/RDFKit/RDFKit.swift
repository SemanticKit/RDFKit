// DO NOT DO EXPORT IMPORTS
// @_exported import RDFCore

import RDFCore

@Ontology struct RDFKit: Ontology {
    var body: some Content {
        Namespace("http://semantickit.io/o/2026/06/rdfkit#")

//        Prefix.rdf
//        Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
//        Prefix.rdfs
//        Prefix.owl

        Class("Namespace") {
            Type(RDFS.Class)
            Comment("Represents the locally defined prefix.")
        }

        Class("Prefix") {
            Type(RDFS.Class)
            Comment("Represents a locally referenced prefix")
        }

        Property("id") {
            Type(RDF.Property)
            Label("alias")
            Domain(RDFKit.Prefix)
            Range(RDFS.Literal)
        }

    }
}
