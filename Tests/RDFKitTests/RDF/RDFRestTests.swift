import Testing
import RDFCore
import RDFKit

@Suite(.tags(.property, .rdf))
struct RDFRestTests {
    /// rdf:rest rdfs:domain rdf:List and rdfs:range rdf:List, so it is a
    /// requirement of RDF.List whose values are lists (D4, D5).
    @Test func isARequirementOfListTypedByList() {
        let list = List()
        let tail = List()
        list.rest.insert(tail)
        #expect(list.rest.contains { $0 === tail })
    }

    private final class List: RDF.List {
        var first: Values<any RDFS.Resource> = []
        var rest: Values<any RDF.List> = []
    }
}
