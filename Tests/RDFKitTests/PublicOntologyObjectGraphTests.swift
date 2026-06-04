import Testing
import RDFKit

@Suite struct PublicOntologyObjectGraphTests {
    @Test func publicOntologyEnvironmentMaterializesFromContent() {
        let ontology = PublicAssetOntology()
        let namespace = Namespace("https://example.com/public-assets#")
        let environment = OntologyEnvironment(content: ontology.content, ownerTypeName: "PublicAssetOntology")

        #expect(environment.namespace == namespace)
        #expect(environment.id == namespace.iri)
        #expect(ontology.environment == environment)
        #expect(ontology.iri == namespace.iri)
    }

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

        let typedAssetDeclaration = try #require(graph.declaration(for: PublicAsset.self))
        #expect(typedAssetDeclaration.iri == asset)
        #expect(graph.declaration(for: IRI("https://example.com/public-control-flow#title"))?.iri == title)
        #expect(graph.facts(for: PublicAsset.self)?.labels == ["Asset"])
        let typedSampleFacts = try #require(graph.facts(for: PublicSampleAsset()))
        #expect(typedSampleFacts.types == [asset])
    }

    @Test func publicObjectGraphMaterializesCompleteFactOntology() throws {
        let graph = try OntologyObjectGraph(PublicCompleteFactOntology())
        let namespace = Namespace("https://example.com/public-facts#")
        let asset = IRI("https://example.com/public-facts#Asset")
        let relation = IRI("https://example.com/public-facts#relation")
        let owner = IRI("https://example.com/public-facts#owner")
        let assetCode = IRI("https://example.com/public-facts#AssetCode")
        let sampleAsset = IRI("https://example.com/public-facts#sampleAsset")
        let rdfProperty = IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Property")
        let rdfsClass = IRI("http://www.w3.org/2000/01/rdf-schema#Class")
        let rdfsResource = IRI("http://www.w3.org/2000/01/rdf-schema#Resource")
        let rdfsDatatype = IRI("http://www.w3.org/2000/01/rdf-schema#Datatype")
        let rdfsLiteral = IRI("http://www.w3.org/2000/01/rdf-schema#Literal")
        let rdfsOntology = IRI("http://www.w3.org/2000/01/rdf-schema#")

        #expect(graph.environment.namespace == namespace)
        #expect(graph.declarations.map(\.iri) == [asset, relation, owner, assetCode, sampleAsset])
        #expect(graph.classes == [asset])
        #expect(graph.properties == [relation, owner])
        #expect(graph.datatypes == [assetCode])
        #expect(graph.individuals == [sampleAsset])

        let assetFacts = try #require(graph.facts[asset])
        #expect(assetFacts.types == [rdfsClass])
        #expect(assetFacts.superclasses == [rdfsResource])
        #expect(assetFacts.labels == ["Asset"])
        #expect(assetFacts.comments == ["A fact-rich public asset."])
        #expect(assetFacts.seeAlso == [rdfsResource])
        #expect(assetFacts.isDefinedBy == [namespace.iri])
        #expect(assetFacts.deprecated == false)

        let relationFacts = try #require(graph.facts[relation])
        #expect(relationFacts.types == [rdfProperty])
        #expect(relationFacts.domains == [asset])
        #expect(relationFacts.ranges == [rdfsResource])
        #expect(relationFacts.labels == ["relation"])

        let ownerFacts = try #require(graph.facts[owner])
        #expect(ownerFacts.types == [rdfProperty])
        #expect(ownerFacts.superproperties == [relation])
        #expect(ownerFacts.domains == [asset])
        #expect(ownerFacts.ranges == [rdfsResource])
        #expect(ownerFacts.labels == ["owner"])
        #expect(ownerFacts.comments == ["The owning resource."])
        #expect(ownerFacts.seeAlso == [asset])
        #expect(ownerFacts.isDefinedBy == [rdfsOntology])

        let assetCodeFacts = try #require(graph.facts[assetCode])
        #expect(assetCodeFacts.types == [rdfsDatatype])
        #expect(assetCodeFacts.superclasses == [rdfsLiteral])
        #expect(assetCodeFacts.deprecated == true)

        let sampleAssetFacts = try #require(graph.facts[sampleAsset])
        #expect(sampleAssetFacts.types == [asset])
        #expect(sampleAssetFacts.seeAlso == [asset])
        #expect(sampleAssetFacts.isDefinedBy == [asset])
    }

    @Test func publicObjectGraphMaterializesCustomVocabulary() throws {
        let valueGraph = try OntologyObjectGraph(PublicCatalogVocabulary())
        let typeGraph = try OntologyObjectGraph(PublicCatalogVocabulary.self)
        let namespace = Namespace("https://example.com/public-catalog#")
        let catalog = IRI("https://example.com/public-catalog#Catalog")
        let entry = IRI("https://example.com/public-catalog#entry")
        let entryCode = IRI("https://example.com/public-catalog#EntryCode")
        let sampleCatalog = IRI("https://example.com/public-catalog#sampleCatalog")
        let rdfProperty = IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Property")
        let rdfsClass = IRI("http://www.w3.org/2000/01/rdf-schema#Class")
        let rdfsDatatype = IRI("http://www.w3.org/2000/01/rdf-schema#Datatype")

        #expect(valueGraph == typeGraph)
        #expect(PublicCatalogVocabulary.iri == namespace.iri)
        #expect(PublicCatalogVocabulary().iri == namespace.iri)
        #expect(valueGraph.environment.namespace == namespace)
        #expect(valueGraph.aliases["catalog"] == namespace.iri)
        #expect(valueGraph.declarations.map(\.iri) == [catalog, entry, entryCode, sampleCatalog])
        #expect(valueGraph.classes == [catalog])
        #expect(valueGraph.properties == [entry])
        #expect(valueGraph.datatypes == [entryCode])
        #expect(valueGraph.individuals == [sampleCatalog])

        let catalogFacts = try #require(valueGraph.facts[catalog])
        #expect(catalogFacts.types == [rdfsClass])
        #expect(catalogFacts.labels == ["Catalog"])
        #expect(catalogFacts.isDefinedBy == [namespace.iri])

        let entryFacts = try #require(valueGraph.facts[entry])
        #expect(entryFacts.types == [rdfProperty])
        #expect(entryFacts.domains == [catalog])
        #expect(entryFacts.ranges == [IRI("http://www.w3.org/2000/01/rdf-schema#Resource")])

        let entryCodeFacts = try #require(valueGraph.facts[entryCode])
        #expect(entryCodeFacts.types == [rdfsDatatype])

        let sampleCatalogFacts = try #require(valueGraph.facts[sampleCatalog])
        #expect(sampleCatalogFacts.types == [catalog])
    }

    @Test func publicObjectGraphMaterializesGroupedDirectStandardTerms() throws {
        let graph = try OntologyObjectGraph(PublicDirectStandardTermOntology())
        let namespace = Namespace("https://example.com/public-direct-standard-terms#")
        let asset = IRI("https://example.com/public-direct-standard-terms#Asset")
        let rdfProperty = IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#Property")
        let rdfLangString = IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")
        let rdfsLabel = IRI("http://www.w3.org/2000/01/rdf-schema#label")
        let rdfsResource = IRI("http://www.w3.org/2000/01/rdf-schema#Resource")
        let owlThing = IRI("http://www.w3.org/2002/07/owl#Thing")

        #expect(graph.environment.namespace == namespace)
        #expect(graph.declarations.map(\.iri) == [asset])
        #expect(graph.classes == [asset, rdfProperty, rdfsResource, owlThing])
        #expect(graph.properties == [rdfsLabel])
        #expect(graph.datatypes == [rdfLangString])
        #expect(graph.terms == [asset, rdfProperty, rdfLangString, rdfsLabel, rdfsResource, owlThing])
    }

    @Test func publicObjectGraphResolvesExternalOntologyScopedTerms() throws {
        let graph = try OntologyObjectGraph(PublicExternalUseOntology())
        let taggedAsset = IRI("https://example.com/public-external-use#TaggedAsset")
        let trackedOwner = IRI("https://example.com/public-external-use#trackedOwner")
        let generatedAssetCode = IRI("https://example.com/public-external-use#GeneratedAssetCode")
        let taggedSample = IRI("https://example.com/public-external-use#taggedSample")
        let externalAsset = IRI("https://example.com/public-external#Asset")
        let externalOwner = IRI("https://example.com/public-external#owner")
        let externalAssetCode = IRI("https://example.com/public-external#AssetCode")
        let externalSample = IRI("https://example.com/public-external#sampleAsset")

        #expect(graph.declarations.map(\.iri) == [taggedAsset, trackedOwner, generatedAssetCode, taggedSample])

        let taggedAssetFacts = try #require(graph.facts[taggedAsset])
        #expect(taggedAssetFacts.superclasses == [externalAsset])
        #expect(taggedAssetFacts.seeAlso == [externalOwner])

        let trackedOwnerFacts = try #require(graph.facts[trackedOwner])
        #expect(trackedOwnerFacts.superproperties == [externalOwner])
        #expect(trackedOwnerFacts.domains == [taggedAsset])
        #expect(trackedOwnerFacts.ranges == [externalAsset])

        let generatedAssetCodeFacts = try #require(graph.facts[generatedAssetCode])
        #expect(generatedAssetCodeFacts.superclasses == [externalAssetCode])

        let taggedSampleFacts = try #require(graph.facts[taggedSample])
        #expect(taggedSampleFacts.types == [taggedAsset])
        #expect(taggedSampleFacts.seeAlso == [externalSample])
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

    private struct PublicCompleteFactOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-facts#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)
            Alias("owl", OWL.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                Annotation {
                    Label("Asset")
                    Comment("A fact-rich public asset.")
                    SeeAlso(RDFS.Resource.self)
                    IsDefinedBy()
                    OWLDeprecated(false)
                }
            }

            Property("relation") {
                Type(RDF.Property.self)
                Domain("Asset")
                Range(RDFS.Resource.self)
                Label("relation")
            }

            Property("owner") {
                Type(RDF.Property.self)
                SubPropertyOf("relation")
                Domain(PublicCompleteFactAsset.self)
                Range(RDFS.Resource.self)
                Annotation {
                    Label("owner")
                    Comment("The owning resource.")
                    SeeAlso(PublicCompleteFactAsset())
                    IsDefinedBy(RDFS())
                }
            }

            Datatype("AssetCode") {
                Type(RDFS.Datatype.self)
                SubClassOf(RDFS.Literal.self)
                OWLDeprecated()
            }

            Individual("sampleAsset") {
                Type("Asset")
                SeeAlso("Asset")
                IsDefinedBy(IRI("https://example.com/public-facts#Asset"))
            }
        }
    }

    private struct PublicDirectStandardTermOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-direct-standard-terms#")

            RDFS.Resource()
            RDF.Property()
            RDFS.Label()
            RDF.LangString()
            OWL.Thing()

            Class("Asset")
        }
    }

    private struct PublicExternalOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-external#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
            }

            Property("owner") {
                Type(RDF.Property.self)
                Domain("Asset")
                Range(RDFS.Resource.self)
            }

            Datatype("AssetCode") {
                Type(RDFS.Datatype.self)
            }

            Individual("sampleAsset") {
                Type("Asset")
            }
        }
    }

    private struct PublicExternalUseOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/public-external-use#")
            Alias("external", IRI("https://example.com/public-external#"))

            Class("TaggedAsset") {
                Type(RDFS.Class.self)
                SubClassOf(PublicExternalAsset.self)
                SeeAlso(PublicExternalOwner())
            }

            Property("trackedOwner") {
                Type(RDF.Property.self)
                SubPropertyOf(PublicExternalOwner.self)
                Domain("TaggedAsset")
                Range(PublicExternalAsset.self)
            }

            Datatype("GeneratedAssetCode") {
                Type(RDFS.Datatype.self)
                SubClassOf(PublicExternalAssetCode.self)
            }

            Individual("taggedSample") {
                Type("TaggedAsset")
                SeeAlso(PublicExternalSampleAsset.self)
            }
        }
    }

    private struct PublicCatalogVocabulary: Vocabulary {
        init() {}

        static var ontology: some Content {
            Namespace("https://example.com/public-catalog#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)
            Alias("catalog", Self.self)

            Class("Catalog") {
                Type(RDFS.Class.self)
                Label("Catalog")
                IsDefinedBy()
            }

            Property("entry") {
                Type(RDF.Property.self)
                Domain("Catalog")
                Range(RDFS.Resource.self)
            }

            Datatype("EntryCode") {
                Type(RDFS.Datatype.self)
            }

            Individual("sampleCatalog") {
                Type("Catalog")
            }
        }
    }

    private struct PublicAsset: OntologyScopedTerm, RDFClass {
        static let ontology = PublicControlFlowOntology()
        static let localName = LocalName("Asset")

        init() {}
    }

    private struct PublicSampleAsset: OntologyScopedTerm, RDFIndividual {
        static let ontology = PublicControlFlowOntology()
        static let localName = LocalName("sampleAsset")

        init() {}
    }

    private struct PublicCompleteFactAsset: OntologyScopedTerm, RDFClass {
        static let ontology = PublicCompleteFactOntology()
        static let localName = LocalName("Asset")

        init() {}
    }

    private struct PublicExternalAsset: OntologyScopedTerm, RDFClass {
        static let ontology = PublicExternalOntology()
        static let localName = LocalName("Asset")

        init() {}
    }

    private struct PublicExternalOwner: OntologyScopedTerm, RDFProperty {
        static let ontology = PublicExternalOntology()
        static let localName = LocalName("owner")

        init() {}
    }

    private struct PublicExternalAssetCode: OntologyScopedTerm, RDFDatatype {
        static let ontology = PublicExternalOntology()
        static let localName = LocalName("AssetCode")

        init() {}
    }

    private struct PublicExternalSampleAsset: OntologyScopedTerm, RDFIndividual {
        static let ontology = PublicExternalOntology()
        static let localName = LocalName("sampleAsset")

        init() {}
    }
}
