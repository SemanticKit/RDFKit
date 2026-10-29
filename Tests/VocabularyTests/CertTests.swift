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
        let key: any Cert.Key = Cert.RSAPublicKeyIndividual(in: IndividualGraph(), modulus: [XSD.hexBinary("010001")], exponent: ["3"])

        #expect(key is any Cert.PublicKey)
        #expect(key is any Cert.RSAKey)
        #expect(!(key is any Cert.PrivateKey))
    }

    @Test("cert:key holds keys that are keys and public keys", .tags(.property, .generated))
    func keyRanges() throws {
        let graph = IndividualGraph()
        let agent = Foaf.AgentIndividual(in: graph)
        let key = Cert.RSAPublicKeyIndividual(in: graph)

        // cert:key has two ranges, so a value is in both.
        let value: Cert.key.Range = key
        let subject: Cert.key.Domain = agent
        Cert.key[subject].append(value)
        #expect(Cert.key[agent].first === key)
    }

    @Test("cert:modulus applies to both of its domains and holds either binary encoding", .tags(.property, .generated))
    func modulusDomains() throws {
        let graph = IndividualGraph()
        let rsa = Cert.RSAKeyIndividual(in: graph, modulus: [XSD.hexBinary("AB")])
        let dsa = Cert.DSAKeyIndividual(in: graph, modulus: [XSD.base64Binary("zQ==")])

        #expect(try #require(rsa.modulus.first as? XSD.hexBinary) == "AB")
        #expect(try #require(dsa.modulus.first as? XSD.base64Binary) == "zQ==")
    }

    @Test("An RSA private exponent of 2048 bits is kept exactly", .tags(.property, .generated))
    func privateExponentIsUnbounded() throws {
        // xsd:nonNegativeInteger is unbounded; a private exponent d is about as
        // large as the modulus: this one is 2048 bits, 617 decimal digits.
        let digits = "2" + String(repeating: "7", count: 615) + "1"
        let key = Cert.RSAPrivateKeyIndividual(in: IndividualGraph(), privateExponent: [XSD.nonNegativeInteger(digits)])

        let exponent = try #require(key.privateExponent.first)
        #expect(exponent.lexicalForm == digits)
        #expect(exponent.lexicalForm.count == 617)
    }

    @Test("A certificate is a FOAF document", .tags(.generated))
    func certificateIsADocument() {
        let graph = IndividualGraph()
        let certificate: any Foaf.Document = Cert.X509CertificateIndividual(in: graph)
        let person = Foaf.PersonIndividual(in: graph)
        certificate.primaryTopic.replace(with: person)

        #expect(certificate is any Cert.Certificate)
        #expect(certificate.primaryTopic.value === person)
    }

    @Test("cert:hex is a datatype, a value", .tags(.generated))
    func hexIsAValue() {
        #expect(Mirror(reflecting: Cert.hex("e1 dc d5")).displayStyle == .struct)
        #expect(Cert.hex.metadata.id == IRI("http://www.w3.org/ns/auth/cert#hex"))
    }
}
