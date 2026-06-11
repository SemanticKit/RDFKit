import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyTests {
    struct SemanticKitOntology: Ontology {
        var content: some Content {
//            Namespace("https://example.com/ontology#")
            Prefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
            Prefix("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
            Prefix("owl", "http://www.w3.org/2002/07/owl#")
        }
    }

    @Test func ontologyUsesExplicitAliasesAndContent() throws {
        let ontology = SemanticKitOntology()

        let rdfAlias = Prefix("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))

        print(rdfAlias)

        print(ontology.content)
    }

    @Test func standardOntologyUsesDirectContentBuilder() {
        _ = RDF.ontology
        _ = RDFS.ontology
        _ = OWL.ontology
    }

}
