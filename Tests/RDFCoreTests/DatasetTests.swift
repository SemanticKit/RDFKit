import IRIKit
import RDFCore
import Testing

@Suite("Dataset", .tags(.graph))
struct DatasetTests {
    let triple = Graph.Element(subject: .iri("http://example/s"), predicate: "http://example/p", object: .literal(Literal("o")))

    @Test("A dataset has one default graph and graphs named by an IRI or a blank node")
    func graphs() throws {
        let iriName: SubjectTerm = .iri("http://example/g")
        let blankName: SubjectTerm = .blankNode(try BlankNode("g"))
        var dataset = Dataset()
        #expect(dataset[nil].isEmpty)

        dataset[nil].insert(triple)
        dataset[iriName] = [triple]
        dataset[blankName].insert(triple)

        #expect(dataset.defaultGraph == [triple])
        #expect(dataset.namedGraphs == [iriName: [triple], blankName: [triple]])
        #expect(dataset[.iri("http://example/missing")].isEmpty)
    }

    @Test("Graph names are unique: setting a name's graph replaces it")
    func uniqueNames() {
        let name: SubjectTerm = .iri("http://example/g")
        var dataset = Dataset(namedGraphs: [name: [triple]])
        dataset[name] = []
        #expect(dataset.namedGraphs.count == 1)
        #expect(dataset[name].isEmpty)
    }
}
