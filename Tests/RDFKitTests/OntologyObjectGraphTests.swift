import Foundation
import Testing
@testable import RDFKit

/// Tests ontology DSL materialization into an object graph.
@Suite struct OntologyObjectGraphTests {
    /// Verifies that production standard ontology DSL content materializes every standards matrix term and fact.
    @Test func standardOntologyDSLContentMaterializesStandardsMatrixObjectGraph() throws {
        let matrix = try StandardsMatrix.bundled()
        let closureFacts = mergedFacts([
            ContentFactResolver.facts(in: RDF.ontology),
            ContentFactResolver.facts(in: RDFS.ontology),
            ContentFactResolver.facts(in: OWL.ontology)
        ])

        try assertObjectGraph(RDF.ontology, covers: matrix.entries(in: "RDF"), closureFacts: closureFacts)
        try assertObjectGraph(RDFS.ontology, covers: matrix.entries(in: "RDFS"), closureFacts: closureFacts)
        try assertObjectGraph(OWL.ontology, covers: matrix.entries(in: "OWL"), closureFacts: closureFacts)
    }

    /// Verifies one ontology content value against the expected standards matrix rows.
    private func assertObjectGraph<ContentValue: Content>(
        _ content: ContentValue,
        covers entries: [VocabularyMatrixEntry],
        closureFacts: [IRI: OntologyDeclarationFacts]
    ) throws {
        let expectedTerms = Set(entries.map(\.iri))
        let facts = ContentFactResolver.facts(in: content)

        #expect(try ContentTermResolver.termIRIs(in: content) == expectedTerms)
        #expect(try ContentTermResolver.classIRIs(in: content) == iris(in: entries, role: .class))
        #expect(try ContentTermResolver.propertyIRIs(in: content) == iris(in: entries, role: .property))
        #expect(try ContentTermResolver.datatypeIRIs(in: content) == iris(in: entries, role: .datatype))
        #expect(try ContentTermResolver.individualIRIs(in: content) == iris(in: entries, role: .individual))
        #expect(facts.count == entries.count)

        for entry in entries {
            let fact = try #require(facts[entry.iri])

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
}
