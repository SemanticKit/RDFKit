import Testing
import IRIKit
import RDFCore
import RDFKit
import ACP

@Suite("Access Control Policy", .tags(.vocabulary))
struct ACPTests {
    @Test("Declares every class, property and named individual of the ACP vocabulary")
    func declaresThePublishedTerms() {
        #expect(Declarations(of: ACP()) == Declarations(classes: 8, properties: 20, individuals: 8))
    }

    @Test("A policy links access controls, matchers and modes as objects", .tags(.property, .generated))
    func policy() throws {
        let read = ACP.AccessModeIndividual()
        let matcher = ACP.MatcherIndividual()
        let policy = ACP.PolicyIndividual(allOf: [matcher], allow: [read])
        let control = ACP.AccessControlIndividual(apply: [policy])
        let resource = ACP.AccessControlResourceIndividual(accessControl: [control])

        let applied = try #require(resource.accessControl.first?.apply.first)
        #expect(applied === policy)
        #expect(policy.allow.first === read)
        #expect(policy.anyOf.isEmpty)

        // acp:agent is a subproperty of acp:attribute with no domain.
        ACP.agent[matcher] = [ACP.PublicAgent]
        #expect(ACP.agent[matcher].first === ACP.PublicAgent)
    }

    @Test("Named individuals are single objects of their classes", .tags(.generated))
    func namedIndividuals() {
        #expect(ACP.PublicAgent is any ACP.AlwaysSatisfiedRestriction)
        #expect(ACP.PublicAgent is any OWL.NamedIndividual)
        #expect(ACP.PublicAgent !== ACP.PublicClient)
        #expect(ACP.AuthenticatedAgent is any OWL.NamedIndividual)
        #expect(type(of: ACP.CreatorAgent).metadata.id == IRI("http://www.w3.org/ns/solid/acp#CreatorAgent"))
    }
}
