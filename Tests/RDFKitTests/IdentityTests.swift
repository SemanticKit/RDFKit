import Testing
@testable import RDFKit

@Suite struct IdentityTests {
    @Test func iriIdentityIsSelf() {
        let iri = IRI("https://example.com/SomeThing")

        #expect(iri.id == iri)
    }

    @Test func equalIRIBackedValuesHaveEqualHashes() {
        let iri = IRI("https://example.com/SomeThing")

        #expect(IRI("https://example.com/SomeThing").hashValue == iri.hashValue)
    }

}
