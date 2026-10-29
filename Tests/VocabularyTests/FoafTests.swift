import Testing
import IRIKit
import RDFCore
import RDFKit
import ReferencedVocabularies
import FOAF

@Suite("FOAF", .tags(.vocabulary))
struct FoafTests {
    @Test("Declares every class and property of FOAF 0.99")
    func declaresThePublishedTerms() {
        #expect(Declarations(of: Foaf()) == Declarations(classes: 13, properties: 62))
    }

    @Test("Functional properties hold at most one value", .tags(.property, .generated))
    func functionalProperties() {
        let alice = Foaf.PersonIndividual(age: "42", gender: "female")
        alice.birthday = "01-31"
        let document = Foaf.DocumentIndividual(primaryTopic: alice)

        // foaf:age, foaf:birthday, foaf:gender and foaf:primaryTopic are functional.
        #expect(alice.age == "42")
        #expect(alice.gender == "female")
        #expect(alice.birthday == "01-31")
        #expect(document.primaryTopic === alice)

        // foaf:firstName and foaf:knows are not.
        alice.firstName = ["Alice", "Ali"]
        #expect(alice.firstName.count == 2)
        #expect(alice.knows.isEmpty)
    }

    @Test("Domains and ranges type the terms", .tags(.property, .generated))
    func domainsAndRanges() throws {
        let alice = Foaf.PersonIndividual()
        let bob = Foaf.PersonIndividual()
        let team = Foaf.GroupIndividual(member: [alice, bob])

        // foaf:knows relates people; foaf:member relates a group to agents.
        let subject: Foaf.knows.Domain = alice
        let object: Foaf.knows.Range = bob
        subject.knows = [object]
        let member: Foaf.member.Range = try #require(team.member.last)
        #expect(member === bob)
        #expect(alice.knows.first === bob)

        // foaf:homepage has the domain owl:Thing and the range foaf:Document.
        let homepage = Foaf.DocumentIndividual()
        Foaf.homepage[team] = [homepage]
        #expect(Foaf.homepage[team].first === homepage)
    }

    @Test("Subclasses refine their superclasses", .tags(.generated))
    func subclasses() {
        let image: any Foaf.Document = Foaf.ImageIndividual()
        let organization: any Foaf.Agent = Foaf.OrganizationIndividual()
        let account: any Foaf.OnlineAccount = Foaf.OnlineChatAccountIndividual(accountName: ["alice"])

        #expect(image is any Foaf.Image)
        #expect(organization is any Foaf.Organization)
        #expect(!(organization is any Foaf.Person))
        #expect(account.accountName == ["alice"])
    }

    @Test("A term's IRI is projected from the namespace at the boundary", .tags(.boundary))
    func iriIsBoundaryProjection() {
        #expect(Foaf.PersonIndividual.metadata.id == IRI("http://xmlns.com/foaf/0.1/Person"))
        #expect(Foaf.knows.metadata.id == IRI("http://xmlns.com/foaf/0.1/knows"))
        #expect(Foaf.knows.metadata.label == "knows")
        #expect(Geo.SpatialThingIndividual.metadata.id == IRI("http://www.w3.org/2003/01/geo/wgs84_pos#SpatialThing"))
    }
}
