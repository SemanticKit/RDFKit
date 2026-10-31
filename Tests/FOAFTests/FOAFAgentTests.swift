import Testing
import RDFKit
import FOAF

@Suite(.tags(.class, .foaf))
struct FOAFAgentTests {
    /// foaf:Agent, translated from index.rdf, is a class whose members are
    /// individuals and resources.
    @Test func isAClassOfIndividuals() {
        let member: AnyObject = Member()
        #expect(member is FOAF.Agent)
        #expect(member is RDFS.Resource)
    }

    private final class Member: FOAF.Agent {}
}
