import Testing
@testable import RDFKit
@testable import IRIKit

@Suite struct IdentityTests {
    @Test func iriIdentityIsSelf() {
        let iri = IRI("https://example.com/SomeThing")

        #expect(iri.id == iri)
    }

    @Test func equalIRIBackedValuesHaveEqualHashes() {
        let iri = IRI("https://example.com/SomeThing")

        #expect(IRI("https://example.com/SomeThing").hashValue == iri.hashValue)
    }

    @Test func namespaceSupportsStringLiteral() {
        let namespace: Namespace = "https://example.com/ontology#"

        #expect(namespace.rawValue == "https://example.com/ontology#")
    }

}
