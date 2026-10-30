import IRIKit
import RDF
import RDFCore

/// The RDFKit vocabulary: the namespaces and prefixes an ontology declares.
@Ontology public struct RDFKit: Ontology {
    public var body: some Content {
        Namespace("http://semantickit.io/o/2026/06/rdfkit#")

        Class("Namespace") {
            Type(RDF.Class)
            Comment("Represents the locally defined prefix.")
        }

        Class("Prefix") {
            Type(RDF.Class)
            Comment("Represents a locally referenced prefix")
        }

        Property("id") {
            Type(RDF.Property)
            Label("alias")
            Domain(RDFKit.Prefix)
            Range(RDF.Literal)
        }
    }
}
