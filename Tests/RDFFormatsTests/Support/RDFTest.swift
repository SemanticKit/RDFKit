import RDFCore
import RDFKit

/// The RDF test vocabulary, which names the kinds of test in the RDF suites.
@Ontology
struct RDFTest: Ontology {
    func content() -> Content {
        Namespace("http://www.w3.org/ns/rdftest#")

        Class("TestNTriplesPositiveSyntax") {
            Type(RDFS.Class)
            Label("N-Triples positive syntax test")
            Comment("A document a decoder accepts.")
        }
        Class("TestNTriplesNegativeSyntax") {
            Type(RDFS.Class)
            Label("N-Triples negative syntax test")
            Comment("A document a decoder rejects.")
        }
        Class("TestNTriplesPositiveC14N") {
            Type(RDFS.Class)
            Label("N-Triples canonicalization test")
            Comment("A document whose canonical N-Triples form is the result.")
        }
        Class("TestTurtlePositiveSyntax") {
            Type(RDFS.Class)
            Label("Turtle positive syntax test")
            Comment("A document a decoder accepts.")
        }
        Class("TestTurtleNegativeSyntax") {
            Type(RDFS.Class)
            Label("Turtle negative syntax test")
            Comment("A document a decoder rejects.")
        }
        Class("TestTurtleEval") {
            Type(RDFS.Class)
            Label("Turtle evaluation test")
            Comment("A document whose graph is isomorphic to the result.")
        }
    }
}
