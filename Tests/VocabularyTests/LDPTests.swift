import Testing
import IRIKit
import RDFCore
import RDFKit
import LDP

@Suite("Linked Data Platform", .tags(.vocabulary))
struct LDPTests {
    @Test("Declares every class, property and individual of the LDP vocabulary")
    func declaresThePublishedTerms() {
        #expect(Declarations(of: LDP()) == Declarations(classes: 9, properties: 13, individuals: 7))
    }

    @Test("Containers are RDF sources and LDP resources", .tags(.generated))
    func containers() {
        let container: any LDP.Resource = LDP.BasicContainerIndividual()

        #expect(container is any LDP.Container)
        #expect(container is any LDP.RDFSource)
        #expect(!(container is any LDP.NonRDFSource))
        #expect(!(container is any LDP.DirectContainer))
    }

    @Test("A container contains resources as objects", .tags(.property, .generated))
    func containment() throws {
        let child = LDP.BasicContainerIndividual()
        let document = LDP.NonRDFSourceIndividual()
        let root = LDP.BasicContainerIndividual(contains: [child, document])
        child.contains = [root]

        let first = try #require(root.contains.first)
        #expect(first === child)
        #expect(try #require(child.contains.first) === root)
        #expect(root.contains.last === document)
    }

    @Test("Preferences and sort orders are named individuals", .tags(.generated))
    func namedIndividuals() {
        #expect(LDP.Ascending !== LDP.Descending)
        #expect(LDP.PreferContainment === LDP.PreferContainment)
        #expect(type(of: LDP.PreferMinimalContainer).metadata.id == IRI("http://www.w3.org/ns/ldp#PreferMinimalContainer"))
    }
}
