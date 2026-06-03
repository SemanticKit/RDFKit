import Testing
@testable import RDFKit

@Suite struct StandardsMatrixTests {
    @Test func bundledMatrixCoversRDFRDFSandOWLTerms() throws {
        let matrix = try StandardsMatrix.bundled()

        #expect(matrix.entries(in: "RDF").count == 22)
        #expect(matrix.entries(in: "RDFS").count == 15)
        #expect(matrix.entries(in: "OWL").count == 77)
        #expect(matrix.entries.count == 114)
    }

    @Test func matrixRecordsRepresentativeDependencyEdges() throws {
        let matrix = try StandardsMatrix.bundled()
        let subClassOf = try #require(matrix.entry(for: RDFS.subClassOf.iri))
        let isDefinedBy = try #require(matrix.entry(for: RDFS.isDefinedBy.iri))

        #expect(subClassOf.role == .property)
        #expect(subClassOf.domain.contains(RDFS.Class.iri))
        #expect(subClassOf.range.contains(RDFS.Class.iri))
        #expect(subClassOf.requiredSwiftProtocols.contains("DomainConstrainedProperty"))
        #expect(isDefinedBy.subpropertyChain.contains(RDFS.seeAlso.iri))
        #expect(isDefinedBy.dependencyEdges.contains(VocabularyDependencyEdge(kind: "subPropertyOf", target: RDFS.seeAlso.iri)))
    }
}
