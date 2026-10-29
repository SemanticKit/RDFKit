import Testing
import IRIKit
import RDFCore
import RDFKit
import ReferencedVocabularies
import FOAF
import ACL

@Suite("Web Access Control", .tags(.vocabulary))
struct ACLTests {
    @Test("Declares every class and property of the ACL vocabulary")
    func declaresThePublishedTerms() {
        #expect(Declarations(of: ACL()) == Declarations(classes: 8, properties: 12))
    }

    @Test("An authorization names its agents, resources and origins as objects", .tags(.property, .generated))
    func authorization() throws {
        let alice = Foaf.PersonIndividual()
        let document = Gen.InformationResourceIndividual()
        let origin = ACL.OriginIndividual()
        let authorization = ACL.AuthorizationIndividual(accessTo: [document], agent: [alice], origin: [origin])

        #expect(try #require(authorization.agent.first) === alice)
        #expect(try #require(authorization.accessTo.first) === document)
        #expect(try #require(authorization.origin.first) === origin)

        // acl:default is a Swift keyword; acl:owner has no domain.
        let container = Gen.InformationResourceIndividual()
        authorization.default = [container]
        ACL.owner[document] = [alice]
        #expect(authorization.default.first === container)
        #expect(ACL.owner[document].first === alice)
    }

    @Test("Access modes refine acl:Access", .tags(.generated))
    func accessModes() {
        let append: any ACL.Access = ACL.AppendIndividual()

        #expect(append is any ACL.Write)
        #expect(!(append is any ACL.Read))
        #expect(ACL.ControlIndividual() is any ACL.Access)
    }

    @Test("Anyone authenticated is a FOAF agent", .tags(.generated))
    func authenticatedAgent() {
        let agent: any Foaf.Agent = ACL.AuthenticatedAgentIndividual()
        #expect(agent is any ACL.AuthenticatedAgent)
        #expect(ACL.agent.metadata.id == IRI("http://www.w3.org/ns/auth/acl#agent"))
    }
}
