import Testing
import RDFCore
import RDFKit
import ReferencedVocabularies
import FOAF
import Cert
import LDP
import Solid

@Suite("A WebID profile built from the generated vocabularies", .tags(.webID, .generated))
struct WebIDProfileTests {

    /// Alice, Bob and Carol know each other in a cycle, and Alice has an RSA key.
    private func profile() -> (alice: Foaf.PersonIndividual, bob: Foaf.PersonIndividual, carol: Foaf.PersonIndividual, key: Cert.RSAPublicKeyIndividual) {
        let graph = IndividualGraph()
        let alice = Foaf.PersonIndividual(in: graph, firstName: ["alice"])
        let bob = Foaf.PersonIndividual(in: graph, firstName: ["bob"], knows: [alice])
        let carol = Foaf.PersonIndividual(in: graph, firstName: ["carol"], knows: [bob])
        alice.knows.append(carol)

        let key = Cert.RSAPublicKeyIndividual(in: graph, identity: [alice], modulus: [XSD.hexBinary("C24F9A01")], exponent: ["65537"])
        Cert.key.values(of: alice).append(key)
        return (alice, bob, carol, key)
    }

    @Test("knows links form a cycle of the same people")
    func knowsCycleKeepsIdentity() throws {
        let (alice, bob, carol, _) = profile()

        // alice -> carol -> bob -> alice
        let first = try #require(alice.knows.first)
        let second = try #require(first.knows.first)
        let third = try #require(second.knows.first)
        #expect(first === carol)
        #expect(second === bob)
        #expect(third === alice)

        // A change made through the cycle is a change to the person.
        third.firstName.append("Alice")
        #expect(alice.firstName.values == ["alice", "Alice"])
    }

    @Test("A person is an agent, a spatial thing and a contact person")
    func personHasEveryClassOfFoafPerson() {
        let (alice, _, _, _) = profile()
        let agent: any Foaf.Agent = alice

        // foaf:Person is a subclass of foaf:Agent, geo:SpatialThing and contact:Person.
        #expect(agent === alice)
        #expect(agent is any Foaf.Person)
        #expect(agent is any Geo.SpatialThing)
        #expect(agent is any Contact.Person)
        #expect(!(agent is any Foaf.Organization))
        #expect(Mirror(reflecting: alice).displayStyle == .class)
    }

    @Test("Cert keys belong to the agent and name it as their identity")
    func certKeysLinkBackToTheirAgent() throws {
        let (alice, _, _, key) = profile()

        // cert:key has the domain foaf:Agent and the ranges cert:Key and cert:PublicKey.
        let found = try #require(Cert.key.values(of: alice).first)
        #expect(found === key)
        #expect(found is any Cert.RSAPublicKey)

        let identity = try #require(key.identity.first)
        #expect(identity === alice)

        // cert:exponent is an xsd:nonNegativeInteger; cert:modulus is a literal
        // of xsd:hexBinary or xsd:base64Binary.
        #expect(key.exponent.values == ["65537"])
        let modulus = try #require(key.modulus.first as? XSD.hexBinary)
        #expect(modulus == "C24F9A01")
    }

    @Test("Another ontology's properties apply to the same person")
    func otherOntologiesDescribeTheSamePerson() throws {
        let (alice, bob, _, _) = profile()
        let graph = try #require(alice.membership.graph)
        let issuer = Foaf.DocumentIndividual(in: graph)
        let inbox = LDP.BasicContainerIndividual(in: graph)
        let account = Solid.AccountIndividual(in: graph)

        // foaf:name has the domain owl:Thing; solid:oidcIssuer, solid:account
        // and ldp:inbox have no domain.
        Foaf.name.values(of: alice).append("Alice")
        Solid.oidcIssuer.values(of: alice).append(issuer)
        Solid.account.values(of: alice).append(account)
        LDP.inbox.values(of: alice).append(inbox)

        #expect(Foaf.name.values(of: alice).values == ["Alice"])
        #expect(Foaf.name.values(of: bob).isEmpty)
        #expect(Solid.oidcIssuer.values(of: alice).first === issuer)
        #expect(Solid.account.values(of: alice).first === account)
        #expect(LDP.inbox.values(of: alice).first === inbox)
        #expect(Solid.account.values(of: bob).isEmpty)
    }

    @Test("The profile document's primary topic is the person")
    func profileDocumentIsAboutThePerson() throws {
        let (alice, _, _, _) = profile()
        let graph = try #require(alice.membership.graph)
        let document = Foaf.PersonalProfileDocumentIndividual(in: graph, primaryTopic: alice)
        Foaf.isPrimaryTopicOf.values(of: alice).append(document)

        // foaf:primaryTopic is functional: at most one value.
        let topic = try #require(document.primaryTopic.value)
        #expect(topic === alice)
        #expect(Foaf.isPrimaryTopicOf.values(of: alice).first === document)
        let asDocument: any Foaf.Document = document
        #expect(asDocument === document)
    }

    @Test("Profiles can be shared across tasks")
    func profilesAreSendable() async throws {
        let (alice, _, _, _) = profile()
        let graph = try #require(alice.membership.graph)
        let friends = (0..<20).map { _ in Foaf.PersonIndividual(in: graph) }

        // Values written from many tasks are all kept, each on its own individual.
        await withTaskGroup { group in
            for (index, friend) in friends.enumerated() {
                group.addTask {
                    friend.knows.append(alice)
                    alice.knows.append(friend)
                    let key = Cert.RSAPublicKeyIndividual(in: graph, identity: [friend], exponent: [XSD.nonNegativeInteger("\(index)")])
                    Cert.key.values(of: friend).append(key)
                }
            }
        }
        #expect(friends.allSatisfy { $0.knows.first === alice })
        #expect(alice.knows.count == friends.count + 1)
        #expect(friends.allSatisfy { friend in
            Cert.key.values(of: friend).count == 1 && Cert.key.values(of: friend).allSatisfy { key in
                key.identity.count == 1 && key.identity.first === friend
            }
        })
    }

    @Test("Concurrent changes to a property of another ontology all land", .tags(.property))
    func concurrentTermChangesAreAtomic() async {
        let graph = IndividualGraph()
        let alice = Foaf.PersonIndividual(in: graph)
        let tasks = 8
        let perTask = 500

        await withTaskGroup { group in
            for task in 0..<tasks {
                group.addTask {
                    for index in 0..<perTask {
                        Foaf.name.values(of: alice).append(RDFS.Literal("\(task)-\(index)"))
                        alice.firstName.update { $0.append(RDFS.Literal("\(task)-\(index)")) }
                    }
                }
            }
        }
        #expect(Foaf.name.values(of: alice).count == tasks * perTask)
        #expect(alice.firstName.count == tasks * perTask)
    }
}
