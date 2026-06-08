import Foundation
import Testing
@testable import RDFKit

@Suite struct OntologyTests {
    struct FixtureGraphContent: GraphContent {
        let subject: IRI

        func write(to graph: inout Graph) throws {
            try graph.insert(Graph.TripleType(
                subject: AnyRDFSubject(subject),
                predicate: RDF.type,
                object: AnyRDFObject(RDFS.Resource.iri)
            ))
        }
    }

    struct SemanticKitOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/ontology#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)
            Alias("owl", OWL.self)
        }
    }

    @Test func ontologyUsesProtocolBasedAliasesAndContent() throws {
        let ontology = SemanticKitOntology()
        let rdfAlias = Alias("rdf", RDF.self)
        let rdfAliasNamespace = try rdfAlias.target.aliasNamespace()

        #expect(ontology.id == IRI("https://example.com/ontology#"))
        #expect(ontology.iri == ontology.id)
        #expect(ontology.environment.namespace == Namespace("https://example.com/ontology#"))
        #expect(ontology.environment.iri == ontology.id)
        #expect(rdfAliasNamespace == Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        _ = ontology.content
    }

    @Test func standardOntologyUsesDirectContentBuilder() {
        _ = RDF.ontology
        _ = RDFS.ontology
        _ = OWL.ontology
    }

    @Test func siblingNamespacesExposeStandardTerms() throws {
        #expect(RDF.type.iri == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"))
        #expect(RDFS.Class.iri == IRI("http://www.w3.org/2000/01/rdf-schema#Class"))
        #expect(OWL.Thing.iri == IRI("http://www.w3.org/2002/07/owl#Thing"))
    }

    @Test func standardNamespacesAreDSLTypes() {
        let namespaces: [any IRIRepresentable] = [RDF(), RDFS(), OWL()]

        #expect(namespaces.count == 3)
        #expect(namespaces.allSatisfy { $0.iri.rawValue.isEmpty == false })
    }

    @Test func contentBuilderComposesTriplesAndTripleParticipatingValues() {
        let subject = IRI("https://example.com/Asset")
        let predicate = RDF.type.iri
        let object = AnyRDFObject(RDFS.Class.iri)
        let triple = Triple(
            subject: subject,
            predicate: predicate,
            object: object
        )
        let content = authoredContent {
            subject
            predicate
            object
            try! Literal("Asset")
            try! BlankNode("asset")
            triple
            RDF.type
            TermReference(RDFS.Class.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
            }
        }

        #expect(content is ContentGroup)
    }

    @Test func graphContentBuilderMaterializesProtocolContent() throws {
        let graph = try makeGraph {
            FixtureGraphContent(subject: IRI("https://example.com/First"))
            FixtureGraphContent(subject: IRI("https://example.com/Second"))
        }

        #expect(graph.triples.count == 2)
    }

    private func makeGraph(@GraphContentBuilder content: () -> some GraphContent) throws -> Graph {
        try content().graph()
    }

    private func authoredContent(@ContentBuilder content: () -> some Content) -> any Content {
        content()
    }

}
