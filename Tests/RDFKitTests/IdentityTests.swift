import Testing
@testable import RDFKit

@Suite struct IdentityTests {
    struct SomeThing: Class, VocabularyTerm {
        static let namespace = Namespace("https://example.com/")
        static let localName = LocalName("SomeThing")

        init() {}
        init(_ ignored: String) {}
    }

    @Test func iriIdentityIsSelf() {
        let iri = IRI("https://example.com/SomeThing")

        #expect(iri.id == iri)
        #expect(iri == SomeThing.self)
        #expect(SomeThing.self == iri)
        #expect(iri == SomeThing("Thing"))
        #expect(SomeThing("Thing") == SomeThing.self)
    }

    @Test func equalIRIBackedValuesHaveEqualHashes() {
        let iri = IRI("https://example.com/SomeThing")
        let instance = SomeThing("Thing")

        #expect(iri.hashValue == instance.hashValue)
        #expect(AnyRDFObject(iri) == AnyRDFObject(instance))
        #expect((try? AnyRDFSubject(iri)) == (try? AnyRDFSubject(instance)))
    }
}
