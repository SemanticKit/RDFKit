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
        let graph = IndividualGraph()
        let alice = Foaf.PersonIndividual(in: graph)
        let document = Gen.InformationResourceIndividual(in: graph)
        let origin = ACL.OriginIndividual(in: graph)
        let authorization = ACL.AuthorizationIndividual(in: graph, accessTo: [document], agent: [alice], origin: [origin])

        #expect(try #require(authorization.agent.first) === alice)
        #expect(try #require(authorization.accessTo.first) === document)
        #expect(try #require(authorization.origin.first) === origin)

        // acl:default is a Swift keyword; acl:owner has no domain.
        let container = Gen.InformationResourceIndividual(in: graph)
        authorization.default.append(container)
        ACL.owner[document].append(alice)
        #expect(authorization.default.first === container)
        #expect(ACL.owner[document].first === alice)
    }

    @Test("Public read access names the class foaf:Agent as a value", .tags(.property, .generated))
    func publicReadAuthorization() throws {
        let graph = IndividualGraph()
        let document = Gen.InformationResourceIndividual(in: graph)
        // <#public> a acl:Authorization; acl:agentClass foaf:Agent;
        //     acl:accessTo <document>; acl:mode acl:Read.
        let authorization = ACL.AuthorizationIndividual(
            in: graph,
            accessTo: [document],
            agentClass: [Foaf.agentClass],
            mode: [ACL.readClass]
        )

        // The class value is one object, an rdfs:Class, at foaf:Agent's IRI.
        let agentClass = try #require(authorization.agentClass.first)
        #expect(agentClass === Foaf.agentClass)
        #expect(agentClass !== Foaf.personClass)
        #expect(agentClass is any OWL.Class)
        #expect(type(of: agentClass).metadata.id == IRI("http://xmlns.com/foaf/0.1/Agent"))
        #expect(authorization.mode.first === ACL.readClass)
        #expect(type(of: ACL.readClass).metadata.id == IRI("http://www.w3.org/ns/auth/acl#Read"))
        // The class value is not an individual of the class it names.
        #expect(!(agentClass is any Foaf.Agent))
    }

    @Test("Access modes refine acl:Access", .tags(.generated))
    func accessModes() {
        let graph = IndividualGraph()
        let append: any ACL.Access = ACL.AppendIndividual(in: graph)

        #expect(append is any ACL.Write)
        #expect(!(append is any ACL.Read))
        #expect(ACL.ControlIndividual(in: graph) is any ACL.Access)
    }

    @Test("Anyone authenticated is a FOAF agent", .tags(.generated))
    func authenticatedAgent() {
        let agent: any Foaf.Agent = ACL.AuthenticatedAgentIndividual(in: IndividualGraph())
        #expect(agent is any ACL.AuthenticatedAgent)
        #expect(ACL.agent.metadata.id == IRI("http://www.w3.org/ns/auth/acl#agent"))
    }
}
