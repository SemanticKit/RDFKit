import Testing
@testable import RDFKit

@Suite struct RDFDSLTests {
    @Test func rdfNamespaceIsAvailable() {
        #expect(RDF.declaredNamespace == Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
    }

    @Test func rdfTypeResourceIsAvailable() {
        #expect(RDF.type.iri == IRI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"))
    }

    @Test func iriParticipatesAsSubjectPredicateAndObject() {
        let iri = IRI("https://example.com/resource")
        let subject: any RDFSubject = iri
        let predicate: any RDFPredicate = iri
        let object: any RDFObject = iri

        #expect(subject.description == iri.description)
        #expect(predicate.description == iri.description)
        #expect(object.description == iri.description)
    }

    @Test func literalParticipatesAsObject() throws {
        let literal = try Literal("value")
        let object: any RDFObject = literal

        #expect(object.description == literal.description)
    }

    @Test func blankNodeParticipatesAsSubjectAndObject() throws {
        let blankNode = try BlankNode("resource")
        let subject: any RDFSubject = blankNode
        let object: any RDFObject = blankNode

        #expect(subject.description == blankNode.description)
        #expect(object.description == blankNode.description)
    }

    @Test func tripleComposesSubjectPredicateAndObject() throws {
        let literal = try Literal("Class")
        let triple = Triple(
            subject: IRI("https://example.com/subject"),
            predicate: RDF.type,
            object: literal
        )

        #expect(triple.subject == IRI("https://example.com/subject"))
        #expect(triple.predicate == RDF.type.iri)
        #expect(triple.object == literal)
    }

    @Test func tripleParticipatesAsContentAndObject() throws {
        let triple = Triple(
            subject: IRI("https://example.com/subject"),
            predicate: RDF.type,
            object: try Literal("Class")
        )
        let content: any Content = triple
        let object: any RDFObject = triple

        #expect(content is Triple<IRI, Literal>)
        #expect(object.description == triple.description)
    }

    @Test func graphAcceptsTriplesAsData() throws {
        let triple = Graph.TripleType(
            subject: AnyRDFSubject(IRI("https://example.com/subject")),
            predicate: RDF.type,
            object: AnyRDFObject(try Literal("Class"))
        )
        var graph = Graph()

        try graph.insert(triple)

        #expect(graph.contains(triple))
    }

    @Test func rdfReifiesCanPointAtTripleObject() throws {
        let triple = Graph.TripleType(
            subject: AnyRDFSubject(IRI("https://example.com/subject")),
            predicate: RDF.type,
            object: AnyRDFObject(try Literal("Class"))
        )
        let reification = Graph.TripleType(
            subject: AnyRDFSubject(IRI("https://example.com/reifier")),
            predicate: RDF.reifies,
            object: AnyRDFObject(triple)
        )
        var graph = Graph()

        try graph.insert(reification)

        #expect(graph.contains(reification))
    }
}
