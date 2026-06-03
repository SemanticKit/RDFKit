import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyTests {
    struct SemanticKitOntology: Ontology {
        let namespace = Namespace("https://example.com/ontology#")

        var aliases: some AliasContent {
            Alias("rdf", RDF.namespace)
            Alias("rdfs", URL(string: RDFS.namespace.rawValue)!)
            Alias("owl", OWL.namespace.rawValue)
        }

        var content: some OntologyContent {
            EmptyContent()
        }
    }

    @Test func ontologyUsesProtocolBasedAliasesAndContent() throws {
        let ontology = SemanticKitOntology()
        let rdfAlias = Alias("rdf", RDF.namespace)
        let rdfAliasNamespace = try rdfAlias.target.aliasNamespace()

        #expect(ontology.id == IRI("https://example.com/ontology#"))
        #expect(ontology.iri == ontology.id)
        #expect(rdfAliasNamespace == RDF.namespace)
        _ = ontology.content
    }

    @Test func siblingNamespacesExposeStandardTerms() throws {
        #expect(RDF.type.iri == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"))
        #expect(RDFS.Class.iri == IRI("http://www.w3.org/2000/01/rdf-schema#Class"))
        #expect(OWL.Thing.iri == IRI("http://www.w3.org/2002/07/owl#Thing"))
    }
}
