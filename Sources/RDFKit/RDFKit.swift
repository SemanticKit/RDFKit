// DO NOT DO EXPORT IMPORTS
// @_exported import RDFCore

import RDFCore

@Ontology struct RDFKit: Ontology {
    func content() -> Content {
        Namespace("http://semantickit.io/o/2026/06/rdfkit#")

        Prefix.rdf
        Prefix.rdfs
        Prefix.owl

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
