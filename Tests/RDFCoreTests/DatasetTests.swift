import RDFCore
import Testing

/// An RDF dataset (RDF 1.2 Concepts §4), holding triples decoded from an
/// N-Triples fixture under names that are their subjects.
@Suite("Dataset", .tags(.graph))
struct DatasetTests {
    @Test("A dataset has one default graph and graphs named by an IRI or a blank node")
    func graphs() throws {
        let graph = try Fixture.graph("dataset.nt")
        let triple = try #require(graph.first)
        let missing = try #require(graph.dropFirst().first).subject
        let iriName = triple.subject
        let blankName: SubjectTerm = .blankNode(try BlankNode("g"))
        var dataset = Dataset()
        #expect(dataset[nil].isEmpty)

        dataset[nil].insert(triple)
        dataset[iriName] = [triple]
        dataset[blankName].insert(triple)

        #expect(dataset.defaultGraph == [triple])
        #expect(dataset.namedGraphs == [iriName: [triple], blankName: [triple]])
        #expect(dataset[missing].isEmpty)
    }

    @Test("Graph names are unique: setting a name's graph replaces it")
    func uniqueNames() throws {
        let triple = try #require(try Fixture.graph("dataset.nt").first)
        let name = triple.subject
        var dataset = Dataset(namedGraphs: [name: [triple]])
        dataset[name] = []
        #expect(dataset.namedGraphs.count == 1)
        #expect(dataset[name].isEmpty)
    }
}
