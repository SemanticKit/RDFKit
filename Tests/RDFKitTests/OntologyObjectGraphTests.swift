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
        let closureFacts = mergedFacts([
            rdfGraph.facts,
            rdfsGraph.facts,
            owlGraph.facts
        ])

        try assertObjectGraph(rdfGraph, covers: matrix.entries(in: "RDF"), closureFacts: closureFacts)
        try assertObjectGraph(rdfsGraph, covers: matrix.entries(in: "RDFS"), closureFacts: closureFacts)
        try assertObjectGraph(owlGraph, covers: matrix.entries(in: "OWL"), closureFacts: closureFacts)

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

    /// Verifies one ontology content value against the expected standards matrix rows.
    private func assertObjectGraph(
        _ graph: OntologyObjectGraph,
        covers entries: [VocabularyMatrixEntry],
        closureFacts: [IRI: OntologyDeclarationFacts]
    ) throws {
        let expectedTerms = Set(entries.map(\.iri))
        let declarationsByIRI = Dictionary(uniqueKeysWithValues: graph.declarations.map { ($0.iri, $0) })

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
            #expect(transitiveObjects(from: entry.iri, in: closureFacts, over: \.superclasses) == Set(entry.subclassChain))
            #expect(transitiveObjects(from: entry.iri, in: closureFacts, over: \.superproperties) == Set(entry.subpropertyChain))
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

    /// Merges independently materialized ontology fact maps.
    private func mergedFacts(_ factMaps: [[IRI: OntologyDeclarationFacts]]) -> [IRI: OntologyDeclarationFacts] {
        factMaps.reduce(into: [:]) { result, facts in
            result.merge(facts) { current, _ in current }
        }
    }

    /// Returns the transitive object closure for one fact relationship.
    private func transitiveObjects(
        from iri: IRI,
        in facts: [IRI: OntologyDeclarationFacts],
        over keyPath: KeyPath<OntologyDeclarationFacts, Set<IRI>>
    ) -> Set<IRI> {
        var visited: Set<IRI> = []
        var queue = Array(facts[iri]?[keyPath: keyPath] ?? [])

        while let next = queue.first {
            queue.removeFirst()

            if visited.insert(next).inserted {
                queue.append(contentsOf: facts[next]?[keyPath: keyPath] ?? [])
            }
        }

        return visited
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
}
