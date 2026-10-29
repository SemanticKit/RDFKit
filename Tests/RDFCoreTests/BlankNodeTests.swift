import RDFCore
import Testing

@Suite("Blank node", .tags(.term))
struct BlankNodeTests {
    @Test("Blank nodes are the same node when their identifiers are equal")
    func identity() throws {
        #expect(try BlankNode("b1") == BlankNode("b1"))
        #expect(try BlankNode("b1") != BlankNode("b2"))
        #expect(try BlankNode("b1").description == "_:b1")
    }

    @Test("A blank node identifier cannot be empty")
    func emptyIdentifier() {
        #expect(throws: TermError.emptyBlankNodeIdentifier) {
            try BlankNode("")
        }
    }
}
