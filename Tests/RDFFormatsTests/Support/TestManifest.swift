import RDFCore
import RDFKit

/// The W3C test manifest vocabulary the RDF test suites are written in.
@Ontology
struct TestManifest: Ontology {
    var body: some Content {
        Namespace("http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#")

        Class("Manifest") {
            Type(RDFS.Class)
            Label("Manifest")
            Comment("A set of tests.")
        }
        Property("include") {
            Label("include")
            Comment("A list of further manifests whose tests belong to this one.")
        }
        Property("entries") {
            Label("entries")
            Comment("The list of tests in this manifest.")
        }
        Property("name") {
            Label("name")
            Comment("The name of a test.")
        }
        Property("action") {
            Label("action")
            Comment("The document a test reads.")
        }
        Property("result") {
            Label("result")
            Comment("The document a test expects.")
        }
    }
}
