import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyTests {
    struct SemanticKitOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/ontology#")
            Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
            Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))
            Alias("owl", Namespace("http://www.w3.org/2002/07/owl#"))
        }
    }

    @Test func ontologyUsesExplicitAliasesAndContent() throws {
        let ontology = SemanticKitOntology()

        let rdfAlias = Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        print(rdfAlias)
        print(ontology.content)
    }

    @Test func standardOntologyUsesDirectContentBuilder() {
        _ = RDF.ontology
        _ = RDFS.ontology
        _ = OWL.ontology
    }

    @Test func contentBuilderComposesOntologyContent() {
        let content = authoredContent {
            Namespace("https://example.com/ontology#")
            Alias("rdf", Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
            Alias("rdfs", Namespace("http://www.w3.org/2000/01/rdf-schema#"))

            Class("Asset") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                Label("Asset")
                Comment("An asset resource.")
            }

            Property("contains") {
                Type(RDF.Property.self)
                Domain("Asset")
                Range(RDFS.Resource.self)
            }
        }

        print(content)
    }

    private func authoredContent(@ContentBuilder content: () -> some Content) -> any Content {
        content()
    }

}
