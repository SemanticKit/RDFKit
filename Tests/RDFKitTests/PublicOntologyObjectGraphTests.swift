import Testing
import RDFKit

@Suite struct PublicOntologyObjectGraphTests {
    @Test func publicObjectGraphMaterializesCustomOntology() throws {
        let graph = try OntologyObjectGraph(PublicAssetOntology())
        let namespace = Namespace("https://example.com/public-assets#")
        let asset = IRI("https://example.com/public-assets#Asset")
        let identifier = IRI("https://example.com/public-assets#identifier")

        #expect(graph.environment.namespace == namespace)
        #expect(graph.aliases["rdf"] == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
        #expect(graph.aliases["rdfs"] == IRI("http://www.w3.org/2000/01/rdf-schema#"))
        #expect(graph.declarations.map(\.iri) == [asset, identifier])
        #expect(graph.classes == [asset])
        #expect(graph.properties == [identifier])
        #expect(graph.terms == [asset, identifier])

        let declaration = try #require(graph.declarations.first)
        #expect(declaration.id == asset)
        #expect(declaration.localName == "Asset")
        #expect(declaration.role == .class)
        #expect(declaration.facts == graph.facts[asset])

        #expect(graph.facts[asset]?.types == [IRI("http://www.w3.org/2000/01/rdf-schema#Class")])
        #expect(graph.facts[asset]?.labels == ["Asset"])
        #expect(graph.facts[asset]?.comments == ["A managed public asset."])
        #expect(graph.facts[asset]?.isDefinedBy == [namespace.iri])

        let identifierDeclaration = try #require(graph.declarations.last)
        let identifierFacts = try #require(graph.facts[identifier])
        #expect(identifierDeclaration.id == identifier)
        #expect(identifierDeclaration.localName == "identifier")
        #expect(identifierDeclaration.role == .property)
        #expect(identifierFacts.types.isEmpty)
        #expect(graph.transitiveSuperclasses[asset] == [])
        #expect(graph.transitiveSuperproperties[identifier] == [])
        #expect(Set(graph.dependencyEdges) == [
            OntologyDependencyEdge(source: asset, kind: .type, target: IRI("http://www.w3.org/2000/01/rdf-schema#Class")),
            OntologyDependencyEdge(source: asset, kind: .isDefinedBy, target: namespace.iri)
        ])
    }

    private struct PublicAssetOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-assets#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                Label("Asset")
                Comment("A managed public asset.")
                IsDefinedBy()
            }

            Property("identifier")
        }
    }
}
