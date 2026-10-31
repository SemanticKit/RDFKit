// DO NOT DO EXPORT IMPORTS
// @_exported import RDFCore

import IRIKit
import RDFCore

@Ontology struct RDFKit: Ontology {
    var content: Content {
        Namespace("http://semantickit.io/o/2026/06/rdfkit#Prefix")

//        Prefix.rdf
//        Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
//        Prefix.rdfs
//        Prefix.owl

        Class("Namespace") {
            Type(RDFS.Class)
            Comment("Represents the locally defined prefix.")
        }

        Class("Prefix") {
            Type(IRIKit.IRI)
            Comment("Represents a locally referenced prefix")
        }

        Property("id") {
            Type(RDF.CompoundLiteral)
            Label("alias")
            Domain("Prefix")
        }

    }
}
