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

    @Test func publicObjectGraphMaterializesControlFlowOntology() throws {
        let graph = try OntologyObjectGraph(PublicControlFlowOntology())
        let namespace = Namespace("https://example.com/public-control-flow#")
        let asset = IRI("https://example.com/public-control-flow#Asset")
        let imageAsset = IRI("https://example.com/public-control-flow#ImageAsset")
        let title = IRI("https://example.com/public-control-flow#title")
        let owner = IRI("https://example.com/public-control-flow#owner")
        let publicAssetCode = IRI("https://example.com/public-control-flow#PublicAssetCode")
        let sampleAsset = IRI("https://example.com/public-control-flow#sampleAsset")

        #expect(graph.environment.namespace == namespace)
        #expect(graph.declarations.map(\.iri) == [asset, imageAsset, title, owner, publicAssetCode, sampleAsset])
        #expect(graph.classes == [asset, imageAsset])
        #expect(graph.properties == [title, owner])
        #expect(graph.datatypes == [publicAssetCode])
        #expect(graph.individuals == [sampleAsset])

        let imageAssetFacts = try #require(graph.facts[imageAsset])
        #expect(imageAssetFacts.superclasses == [asset])

        let titleFacts = try #require(graph.facts[title])
        #expect(titleFacts.domains == [asset])
        #expect(titleFacts.ranges == [IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")])

        let ownerFacts = try #require(graph.facts[owner])
        #expect(ownerFacts.domains == [asset])
        #expect(ownerFacts.ranges == [IRI("http://www.w3.org/2000/01/rdf-schema#Resource")])

        let sampleAssetFacts = try #require(graph.facts[sampleAsset])
        #expect(sampleAssetFacts.types == [asset])
        #expect(sampleAssetFacts.labels == ["Sample public asset"])
    }

    private struct PublicAssetOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-assets#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                Annotation {
                    Label("Asset")
                    Comment("A managed public asset.")
                    IsDefinedBy()
                }

                Property("identifier")
            }
        }
    }

    private struct PublicControlFlowOntology: Ontology {
        static let properties = ["title", "owner"]
        static let includeSample = true

        var content: some Content {
            Namespace("https://example.com/public-control-flow#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                if Self.includeSample {
                    Label("Asset")
                }
                Class("ImageAsset") {
                    Type(RDFS.Class.self)
                    SubClassOf("Asset")
                }
            }

            for property in Self.properties {
                Property(property) {
                    Type(RDF.Property.self)
                    Domain("Asset")
                    if property == "title" {
                        Range(RDF.LangString.self)
                    } else {
                        Range(RDFS.Resource.self)
                    }
                }
            }

            Datatype("PublicAssetCode") {
                Type(RDFS.Datatype.self)
            }

            if Self.includeSample {
                Individual("sampleAsset") {
                    Type("Asset")
                    Annotation {
                        Label("Sample public asset")
                    }
                }
            }
        }
    }
}
