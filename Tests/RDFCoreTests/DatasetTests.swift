import RDFCore
import Testing

@Suite("Dataset", .tags(.graph))
struct DatasetTests {
    /// The triple the graphs hold, and the IRI that names a graph, from
    /// `dataset.ttl`.
    let triple: Graph.Element
    let iriName: SubjectTerm

    init() throws {
        let document = try Graph(fixture: "dataset.ttl")
        triple = document[0]
        iriName = document[1].subject
    }

    @Test("A dataset has one default graph and graphs named by an IRI or a blank node")
    func graphs() throws {
        let blankName: SubjectTerm = .blankNode(try BlankNode("g"))
        var dataset = Dataset()
        #expect(dataset[nil].isEmpty)

        dataset[nil].insert(triple)
        dataset[iriName] = [triple]
        dataset[blankName].insert(triple)

        #expect(dataset.defaultGraph == [triple])
        #expect(dataset.namedGraphs == [iriName: [triple], blankName: [triple]])
        // The predicate's IRI names no graph.
        #expect(dataset[.iri(triple.predicate)].isEmpty)
    }

    @Test("Graph names are unique: setting a name's graph replaces it")
    func uniqueNames() {
        var dataset = Dataset(namedGraphs: [iriName: [triple]])
        dataset[iriName] = []
        #expect(dataset.namedGraphs.count == 1)
        #expect(dataset[iriName].isEmpty)
    }
}
