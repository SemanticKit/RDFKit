import Foundation
import Testing
@testable import RDFKit

/// Tests ontology DSL materialization into an object graph.
@Suite struct OntologyObjectGraphTests {
    /// Verifies that production standard ontology DSL content materializes every standards matrix term and fact.
    @Test func standardOntologyDSLContentMaterializesStandardsMatrixObjectGraph() throws {
        let matrix = try StandardsMatrix.bundled()
        let rdfGraph = try OntologyObjectGraph(RDF())
        let rdfsGraph = try OntologyObjectGraph(RDFS())
        let owlGraph = try OntologyObjectGraph(OWL())
        let standardsGraph = try rdfGraph
            .merging(with: rdfsGraph)
            .merging(with: owlGraph)

        try assertObjectGraph(rdfGraph, covers: matrix.entries(in: "RDF"), closureGraph: standardsGraph)
        try assertObjectGraph(rdfsGraph, covers: matrix.entries(in: "RDFS"), closureGraph: standardsGraph)
        try assertObjectGraph(owlGraph, covers: matrix.entries(in: "OWL"), closureGraph: standardsGraph)

        #expect(rdfGraph.aliases["rdf"] == RDF.declaredNamespace.iri)
        #expect(rdfGraph.aliases["rdfs"] == RDFS.declaredNamespace.iri)
        #expect(rdfGraph.aliases["owl"] == OWL.declaredNamespace.iri)
        #expect(rdfsGraph.aliases["rdf"] == RDF.declaredNamespace.iri)
        #expect(rdfsGraph.aliases["rdfs"] == RDFS.declaredNamespace.iri)
        #expect(rdfsGraph.aliases["owl"] == OWL.declaredNamespace.iri)
        #expect(owlGraph.aliases["rdf"] == RDF.declaredNamespace.iri)
        #expect(owlGraph.aliases["rdfs"] == RDFS.declaredNamespace.iri)
        #expect(owlGraph.aliases["owl"] == OWL.declaredNamespace.iri)
    }

    /// Verifies that a new ontology authored in the DSL materializes into an object graph.
    @Test func customOntologyDSLContentMaterializesObjectGraph() throws {
        let graph = try OntologyObjectGraph(CustomAssetOntology())
        let namespace = Namespace("https://example.com/assets#")
        let asset = QualifiedName(namespace: namespace, localName: LocalName("Asset")).iri
        let name = QualifiedName(namespace: namespace, localName: LocalName("name")).iri

        #expect(graph.environment.namespace == namespace)
        #expect(graph.environment.iri == namespace.iri)
        #expect(graph.aliases["rdf"] == RDF.declaredNamespace.iri)
        #expect(graph.aliases["rdfs"] == RDFS.declaredNamespace.iri)
        #expect(graph.declarations.map(\.iri) == [asset, name])
        #expect(graph.terms == [asset, name])
        #expect(graph.classes == [asset])
        #expect(graph.properties == [name])
        #expect(graph.datatypes == [])
        #expect(graph.individuals == [])
        #expect(graph.transitiveSuperclasses[asset] == [RDFS.Resource.iri])
        #expect(graph.transitiveSuperproperties[name] == [])

        let assetDeclaration = try #require(graph.declarations.first)
        #expect(assetDeclaration.id == asset)
        #expect(assetDeclaration.localName == "Asset")
        #expect(assetDeclaration.role == .class)

        let assetFacts = try #require(graph.facts[asset])
        #expect(assetFacts.types == [RDFS.Class.iri])
        #expect(assetFacts.superclasses == [RDFS.Resource.iri])
        #expect(assetFacts.labels == ["Asset"])
        #expect(assetFacts.isDefinedBy == [namespace.iri])
        #expect(assetDeclaration.facts == assetFacts)

        let nameDeclaration = try #require(graph.declarations.last)
        #expect(nameDeclaration.id == name)
        #expect(nameDeclaration.localName == "name")
        #expect(nameDeclaration.role == .property)

        let nameFacts = try #require(graph.facts[name])
        #expect(nameFacts.types == [RDF.Property.iri])
        #expect(nameFacts.domains == [asset])
        #expect(nameFacts.ranges == [RDF.LangString.iri])
        #expect(nameFacts.labels == ["name"])
        #expect(nameFacts.isDefinedBy == [namespace.iri])
        #expect(nameDeclaration.facts == nameFacts)
        #expect(Set(graph.dependencyEdges) == [
            OntologyDependencyEdge(source: asset, kind: .type, target: RDFS.Class.iri),
            OntologyDependencyEdge(source: asset, kind: .subClassOf, target: RDFS.Resource.iri),
            OntologyDependencyEdge(source: asset, kind: .isDefinedBy, target: namespace.iri),
            OntologyDependencyEdge(source: name, kind: .type, target: RDF.Property.iri),
            OntologyDependencyEdge(source: name, kind: .domain, target: asset),
            OntologyDependencyEdge(source: name, kind: .range, target: RDF.LangString.iri),
            OntologyDependencyEdge(source: name, kind: .isDefinedBy, target: namespace.iri)
        ])
    }

    /// Verifies that declaration blocks can be authored without body boilerplate.
    @Test func emptyDeclarationDSLContentMaterializesObjectGraph() throws {
        let graph = try OntologyObjectGraph(EmptyDeclarationOntology())
        let namespace = Namespace("https://example.com/empty-declarations#")
        let asset = QualifiedName(namespace: namespace, localName: LocalName("Asset")).iri
        let name = QualifiedName(namespace: namespace, localName: LocalName("name")).iri
        let code = QualifiedName(namespace: namespace, localName: LocalName("AssetCode")).iri
        let root = QualifiedName(namespace: namespace, localName: LocalName("root")).iri

        #expect(graph.declarations.map(\.iri) == [asset, name, code, root])
        #expect(graph.classes == [asset])
        #expect(graph.properties == [name])
        #expect(graph.datatypes == [code])
        #expect(graph.individuals == [root])
        #expect(graph.facts[asset]?.types.isEmpty == true)
        #expect(graph.facts[name]?.types.isEmpty == true)
        #expect(graph.facts[code]?.types.isEmpty == true)
        #expect(graph.facts[root]?.types.isEmpty == true)
    }

    /// Verifies that annotation blocks materialize declaration facts without changing declaration roles.
    @Test func annotationDSLContentMaterializesObjectGraphFacts() throws {
        let graph = try OntologyObjectGraph(AnnotatedAssetOntology())
        let namespace = Namespace("https://example.com/annotated-assets#")
        let asset = QualifiedName(namespace: namespace, localName: LocalName("Asset")).iri
        let owner = QualifiedName(namespace: namespace, localName: LocalName("owner")).iri

        #expect(graph.declarations.map(\.iri) == [asset, owner])
        #expect(graph.classes == [asset])
        #expect(graph.properties == [owner])

        let assetFacts = try #require(graph.facts[asset])
        #expect(assetFacts.types == [RDFS.Class.iri])
        #expect(assetFacts.labels == ["Asset"])
        #expect(assetFacts.comments == ["A managed asset."])
        #expect(assetFacts.seeAlso == [RDFS.Resource.iri])
        #expect(assetFacts.isDefinedBy == [namespace.iri])

        let ownerFacts = try #require(graph.facts[owner])
        #expect(ownerFacts.types == [RDF.Property.iri])
        #expect(ownerFacts.domains == [asset])
        #expect(ownerFacts.ranges == [RDFS.Resource.iri])
        #expect(ownerFacts.labels == ["owner"])
        #expect(ownerFacts.comments == ["The resource that owns an asset."])
    }

    /// Verifies that class bodies can declare reusable properties.
    @Test func classBodyDeclarationMaterializesNestedProperty() throws {
        let graph = try OntologyObjectGraph(ClassWithPropertyOntology())
        let namespace = Namespace("https://example.com/class-properties#")
        let asset = QualifiedName(namespace: namespace, localName: LocalName("Asset")).iri
        let owner = QualifiedName(namespace: namespace, localName: LocalName("owner")).iri

        #expect(graph.declarations.map(\.iri) == [asset, owner])
        #expect(graph.classes == [asset])
        #expect(graph.properties == [owner])

        let assetFacts = try #require(graph.facts[asset])
        #expect(assetFacts.types == [RDFS.Class.iri])
        #expect(assetFacts.labels == ["Asset"])
        #expect(assetFacts.domains == [])
        #expect(assetFacts.ranges == [])

        let ownerFacts = try #require(graph.facts[owner])
        #expect(ownerFacts.types == [RDF.Property.iri])
        #expect(ownerFacts.domains == [asset])
        #expect(ownerFacts.ranges == [RDFS.Resource.iri])
        #expect(ownerFacts.labels == ["owner"])
    }

    /// Verifies one ontology content value against the expected standards matrix rows.
    private func assertObjectGraph(
        _ graph: OntologyObjectGraph,
        covers entries: [VocabularyMatrixEntry],
        closureGraph: OntologyObjectGraph
    ) throws {
        let expectedTerms = Set(entries.map(\.iri))
        let declarationsByIRI = Dictionary(uniqueKeysWithValues: graph.declarations.map { ($0.iri, $0) })
        let edgesBySource = Dictionary(grouping: closureGraph.dependencyEdges, by: \.source)

        #expect(graph.terms == expectedTerms)
        #expect(Set(graph.declarations.map(\.iri)) == expectedTerms)
        #expect(graph.declarations.count == entries.count)
        #expect(graph.classes == iris(in: entries, role: .class))
        #expect(graph.properties == iris(in: entries, role: .property))
        #expect(graph.datatypes == iris(in: entries, role: .datatype))
        #expect(graph.individuals == iris(in: entries, role: .individual))
        #expect(graph.facts.count == entries.count)

        for entry in entries {
            let declaration = try #require(declarationsByIRI[entry.iri])
            let fact = try #require(graph.facts[entry.iri])

            #expect(declaration.localName == entry.localName)
            #expect(vocabularyRole(for: declaration.role) == entry.role)
            #expect(declaration.facts == fact)
            #expect(fact.types == Set(entry.directTypes))
            #expect(closureGraph.transitiveSuperclasses[entry.iri] == Set(entry.subclassChain))
            #expect(closureGraph.transitiveSuperproperties[entry.iri] == Set(entry.subpropertyChain))
            let expectedEdges = try dependencyEdges(for: entry)
            #expect(Set(edgesBySource[entry.iri] ?? []) == expectedEdges)
            #expect(fact.domains == Set(entry.domain))
            #expect(fact.ranges == Set(entry.range))
            #expect(fact.labels == Set(entry.labels))
            #expect(fact.comments == Set(entry.comments))
            #expect(fact.seeAlso == Set(entry.seeAlso))
            #expect(fact.isDefinedBy == Set(entry.isDefinedBy))
        }
    }

    /// Returns all expected IRIs for one matrix role.
    private func iris(in entries: [VocabularyMatrixEntry], role: VocabularyRole) -> Set<IRI> {
        Set(entries.filter { $0.role == role }.map(\.iri))
    }

    /// Returns the standards matrix role represented by an ontology declaration role.
    private func vocabularyRole(for role: OntologyDeclarationRole) -> VocabularyRole {
        switch role {
        case .class:
            .class
        case .property:
            .property
        case .datatype:
            .datatype
        case .individual:
            .individual
        }
    }

    /// Returns the dependency edges expected from a standards matrix row.
    private func dependencyEdges(for entry: VocabularyMatrixEntry) throws -> Set<OntologyDependencyEdge> {
        Set(try entry.dependencyEdges.map { edge in
            let kind = try #require(OntologyDependencyKind(rawValue: edge.kind))
            return OntologyDependencyEdge(source: entry.iri, kind: kind, target: edge.target)
        })
    }

    /// A custom ontology authored with the same DSL as the standards.
    private struct CustomAssetOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/assets#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                SubClassOf(RDFS.Resource.self)
                Label("Asset")
                IsDefinedBy()
            }

            Property("name") {
                Type(RDF.Property.self)
                Domain(IRI("https://example.com/assets#Asset"))
                Range(RDF.LangString.self)
                Label("name")
                IsDefinedBy()
            }
        }
    }

    /// A custom ontology using clean empty declarations.
    private struct EmptyDeclarationOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/empty-declarations#")

            Class("Asset")
            Property("name")
            Datatype("AssetCode")
            Individual("root")
        }
    }

    /// A custom ontology using annotation blocks inside declarations.
    private struct AnnotatedAssetOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/annotated-assets#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                Annotation {
                    Label("Asset")
                    Comment("A managed asset.")
                    SeeAlso(RDFS.Resource.self)
                    IsDefinedBy()
                }
            }

            Property("owner") {
                Type(RDF.Property.self)
                Domain(IRI("https://example.com/annotated-assets#Asset"))
                Range(RDFS.Resource.self)
                Annotation {
                    Label("owner")
                    Comment("The resource that owns an asset.")
                }
            }
        }
    }

    /// A custom ontology declaring a property inside class content.
    private struct ClassWithPropertyOntology: Ontology {
        var content: some Content {
            Namespace("https://example.com/class-properties#")
            Alias("rdf", RDF.self)
            Alias("rdfs", RDFS.self)

            Class("Asset") {
                Type(RDFS.Class.self)
                Label("Asset")

                Property("owner") {
                    Type(RDF.Property.self)
                    Domain(IRI("https://example.com/class-properties#Asset"))
                    Range(RDFS.Resource.self)
                    Label("owner")
                }
            }
        }
    }
}
