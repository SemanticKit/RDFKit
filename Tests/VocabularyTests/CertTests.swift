import Testing
import IRIKit
import RDFCore
import RDFKit
import FOAF
import Cert

@Suite("Cert", .tags(.vocabulary))
struct CertTests {
    @Test("Declares every published term, and the two classes it names without declaring")
    func declaresThePublishedTerms() {
        // 9 published classes, and cert:DSAKey and cert:RSAPrivateKey.
        #expect(Declarations(of: Cert()) == Declarations(classes: 11, datatypes: 1, properties: 5))
    }

    @Test("An RSA public key is a public key and an RSA key", .tags(.generated))
    func rsaPublicKey() {
        let key: any Cert.Key = Cert.RSAPublicKeyIndividual(modulus: [[0x01, 0x00, 0x01]], exponent: [3])

        #expect(key is any Cert.PublicKey)
        #expect(key is any Cert.RSAKey)
        #expect(!(key is any Cert.PrivateKey))
    }

    @Test("cert:key holds keys that are keys and public keys", .tags(.property, .generated))
    func keyRanges() throws {
        let agent = Foaf.AgentIndividual()
        let key = Cert.RSAPublicKeyIndividual()

        // cert:key has two ranges, so a value is in both.
        let value: Cert.key.Range = key
        let subject: Cert.key.Domain = agent
        Cert.key[subject] = [value]
        #expect(try #require(Cert.key[agent].first) === key)
    }

    @Test("cert:modulus applies to both of its domains", .tags(.property, .generated))
    func modulusDomains() {
        let rsa = Cert.RSAKeyIndividual(modulus: [[0xAB]])
        let dsa = Cert.DSAKeyIndividual(modulus: [[0xCD]])

        #expect(Cert.modulus[rsa] == [[0xAB]])
        #expect(Cert.modulus[dsa] == [[0xCD]])
    }

    @Test("A certificate is a FOAF document", .tags(.generated))
    func certificateIsADocument() {
        let certificate: any Foaf.Document = Cert.X509CertificateIndividual()
        let person = Foaf.PersonIndividual()
        certificate.primaryTopic = person

        #expect(certificate is any Cert.Certificate)
        #expect(certificate.primaryTopic === person)
    }

    @Test("cert:hex is a datatype, a value", .tags(.generated))
    func hexIsAValue() {
        #expect(Mirror(reflecting: Cert.hex()).displayStyle == .struct)
        #expect(Cert.hex.metadata.id == IRI("http://www.w3.org/ns/auth/cert#hex"))
    }
}
