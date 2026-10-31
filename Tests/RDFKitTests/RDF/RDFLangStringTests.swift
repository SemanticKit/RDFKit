import Testing
import RDFKit

@Suite(.tags(.class, .rdf))
struct RDFLangStringTests {
    /// rdf:langString rdfs:subClassOf rdfs:Literal: its values are Swift value
    /// types (D6), and they are literals and resources.
    @Test func aValueTypeIsAMember() {
        let value: Any = Value()
        #expect(value is RDF.langString)
        #expect(value is RDFS.Literal)
        #expect(value is RDFS.Resource)
    }

    private struct Value: RDF.langString {}
}
