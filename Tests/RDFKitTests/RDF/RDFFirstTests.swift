import Testing
import RDFCore
import RDFKit

@Suite(.tags(.property, .rdf))
struct RDFFirstTests {
    /// rdf:first rdfs:domain rdf:List, so it is a requirement of RDF.List,
    /// typed by its range, rdfs:Resource (D4, D5).
    @Test func isARequirementOfList() {
        let list = List()
        let item = Item()
        list.first.insert(item)
        list.first.insert(item)
        #expect(list.first.count == 1)
        #expect(list.first.contains { ($0 as AnyObject) === item })
    }

    private final class List: RDF.List {
        var first: Values<any RDFS.Resource> = []
        var rest: Values<any RDF.List> = []
    }

    private final class Item: RDFS.Resource {}
}
