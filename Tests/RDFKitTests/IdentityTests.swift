import Testing
@testable import RDFKit

@Suite struct IdentityTests {
    struct SomeThing: NamespaceTerm {
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

    @Test func equalIRIBackedValuesHaveEqualHashes() throws {
        let iri = IRI("https://example.com/SomeThing")
        let instance = SomeThing("Thing")
        let iriSubject = AnyRDFSubject(iri)
        let instanceSubject = try AnyRDFSubject(instance)

        #expect(iri.hashValue == instance.hashValue)
        #expect(AnyRDFObject(iri) == AnyRDFObject(instance))
        #expect(iriSubject == instanceSubject)
    }

    @Test func iriBackedReferencesShareIdentityEquality() {
        let iri = RDF.type.iri
        let value = RDF.type
        let type = RDF.TypeTerm.self
        let valueReference = TermReference(value)
        let typeReference = TermReference(type)

        #expect(iri == value)
        #expect(value == iri)
        #expect(iri == type)
        #expect(type == iri)
        #expect(value == type)
        #expect(type == value)
        #expect(iri == valueReference)
        #expect(valueReference == iri)
        #expect(valueReference == type)
        #expect(type == valueReference)
        #expect(valueReference == typeReference)
        #expect(valueReference.hashValue == iri.hashValue)
        #expect(typeReference.hashValue == iri.hashValue)
    }

}
