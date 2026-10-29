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
        let alice = Foaf.PersonIndividual(firstName: ["alice"])
        let bob = Foaf.PersonIndividual(firstName: ["bob"], knows: [alice])
        let carol = Foaf.PersonIndividual(firstName: ["carol"], knows: [bob])
        alice.knows = [carol]

        let key = Cert.RSAPublicKeyIndividual(identity: [alice], modulus: [[0xC2, 0x4F, 0x9A, 0x01]], exponent: [65537])
        Cert.key[alice] = [key]
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
        #expect(alice.firstName == ["alice", "Alice"])
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
        let keys = Cert.key[alice]
        let found = try #require(keys.first)
        #expect(found === key)
        #expect(found is any Cert.RSAPublicKey)

        let identity = try #require(key.identity.first)
        #expect(identity === alice)

        // cert:exponent is an xsd:nonNegativeInteger, cert:modulus an xsd:hexBinary.
        #expect(key.exponent == [65537])
        #expect(key.modulus.first == [0xC2, 0x4F, 0x9A, 0x01])
    }

    @Test("Another ontology's properties apply to the same person")
    func otherOntologiesDescribeTheSamePerson() throws {
        let (alice, bob, _, _) = profile()
        let issuer = Foaf.DocumentIndividual()
        let inbox = LDP.BasicContainerIndividual()
        let account = Solid.AccountIndividual()

        // foaf:name has the domain owl:Thing; solid:oidcIssuer, solid:account
        // and ldp:inbox have no domain.
        Foaf.name[alice] = ["Alice"]
        Solid.oidcIssuer[alice] = [issuer]
        Solid.account[alice] = [account]
        LDP.inbox[alice] = [inbox]

        #expect(Foaf.name[alice] == ["Alice"])
        #expect(Foaf.name[bob].isEmpty)
        #expect(try #require(Solid.oidcIssuer[alice].first) === issuer)
        #expect(try #require(Solid.account[alice].first) === account)
        #expect(try #require(LDP.inbox[alice].first) === inbox)

        // A property is the same values through its term and its class member.
        Foaf.knows[alice].append(bob)
        #expect(alice.knows.count == 2)
        #expect(alice.knows.last === bob)
    }

    @Test("The profile document's primary topic is the person")
    func profileDocumentIsAboutThePerson() throws {
        let (alice, _, _, _) = profile()
        let document = Foaf.PersonalProfileDocumentIndividual(primaryTopic: alice)
        Foaf.isPrimaryTopicOf[alice] = [document]

        // foaf:primaryTopic is functional: at most one value.
        let topic = try #require(document.primaryTopic)
        #expect(topic === alice)
        #expect(try #require(Foaf.isPrimaryTopicOf[alice].first) === document)
        #expect(document is any Foaf.Document)
    }

    @Test("Profiles can be shared across tasks")
    func profilesAreSendable() async {
        let (alice, _, _, key) = profile()
        let friends = (0..<20).map { _ in Foaf.PersonIndividual() }

        await withTaskGroup { group in
            for friend in friends {
                group.addTask {
                    friend.knows = [alice]
                    Cert.key[friend] = [key]
                }
            }
        }
        #expect(friends.allSatisfy { $0.knows.first === alice && Cert.key[$0].first === key })
    }
}
