import IRIKit
import RDF
import RDFCore
import RDFKit

/// The RDF test vocabulary, which names the kinds of test in the RDF suites.
@Ontology
struct RDFTest: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/ns/rdftest#")

        Class("TestNTriplesPositiveSyntax") {
            Type(RDF.Class)
            Label("N-Triples positive syntax test")
            Comment("A document a decoder accepts.")
        }
        Class("TestNTriplesNegativeSyntax") {
            Type(RDF.Class)
            Label("N-Triples negative syntax test")
            Comment("A document a decoder rejects.")
        }
        Class("TestNTriplesPositiveC14N") {
            Type(RDF.Class)
            Label("N-Triples canonicalization test")
            Comment("A document whose canonical N-Triples form is the result.")
        }
        Class("TestTurtlePositiveSyntax") {
            Type(RDF.Class)
            Label("Turtle positive syntax test")
            Comment("A document a decoder accepts.")
        }
        Class("TestTurtleNegativeSyntax") {
            Type(RDF.Class)
            Label("Turtle negative syntax test")
            Comment("A document a decoder rejects.")
        }
        Class("TestTurtleEval") {
            Type(RDF.Class)
            Label("Turtle evaluation test")
            Comment("A document whose graph is isomorphic to the result.")
        }
        Class("TestXMLEval") {
            Type(RDF.Class)
            Label("RDF/XML evaluation test")
            Comment("A document whose graph is isomorphic to the result.")
        }
        Class("TestXMLNegativeSyntax") {
            Type(RDF.Class)
            Label("RDF/XML negative syntax test")
            Comment("A document a decoder rejects.")
        }
    }
}
