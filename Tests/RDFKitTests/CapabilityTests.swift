import Testing
@testable import RDFKit

@Suite struct CapabilityTests {
    @Test func graphAndDatasetStoreReplacementModelTerms() throws {
        let subject = IRI("https://example.com/s")
        let predicate = IRI("https://example.com/p")
        let object = try Literal("value")
        let triple = Graph.TripleType(
            subject: try AnyRDFSubject(subject),
            predicate: predicate,
            object: AnyRDFObject(object)
        )

        var graph = Graph()
        try graph.insert(triple)
        let dataset = try Dataset().inserting(graph)

        #expect(graph.contains(triple))
        #expect(dataset.defaultGraph.contains(triple))
    }

    @Test func nTriplesAndNQuadsRoundTripThroughSharedModel() throws {
        let ntriples = "<https://example.com/s> <https://example.com/p> \"hello\"@en ."
        let graph = try Graph(ntriples: ntriples)
        let dataset = try Dataset().inserting(graph)
        let reparsed = try Dataset(nquads: dataset.nquadsString())

        #expect(graph.ntriplesString().contains("\"hello\"@en"))
        #expect(reparsed.defaultGraph.triples == graph.triples)
    }

    @Test func turtleRDFXMLAndOWLFunctionalSyntaxProduceGraphContent() throws {
        let turtle = """
        @prefix ex: <https://example.com/> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        ex:Person rdfs:label "Person" .
        """
        let turtleGraph = try Graph(turtle: turtle)

        let rdfxml = """
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
          <rdf:Description rdf:about="https://example.com/Person">
            <rdfs:label>Person</rdfs:label>
          </rdf:Description>
        </rdf:RDF>
        """
        let rdfxmlGraph = try Graph(rdfxml: rdfxml)

        let functional = """
        Ontology(<https://example.com/ontology>
            Declaration(Class(<https://example.com/Person>))
            AnnotationAssertion(<http://www.w3.org/2000/01/rdf-schema#label> <https://example.com/Person> "Person")
        )
        """
        let owlGraph = try Graph(owlFunctionalSyntax: functional)
        let person = try AnyRDFSubject(IRI("https://example.com/Person"))
        let label = IRI("http://www.w3.org/2000/01/rdf-schema#label")
        let literal = AnyRDFObject(try Literal("Person"))

        #expect(turtleGraph.contains(Graph.TripleType(subject: person, predicate: label, object: literal)))
        #expect(rdfxmlGraph.contains(Graph.TripleType(subject: person, predicate: label, object: literal)))
        #expect(owlGraph.contains(Graph.TripleType(subject: person, predicate: label, object: literal)))
    }

    @Test func reificationAndRDFSClosureUseReplacementNamespaces() throws {
        let person = IRI("https://example.com/Person")
        let agent = IRI("https://example.com/Agent")
        let alice = IRI("https://example.com/Alice")
        let reifier = IRI("https://example.com/statement")
        let typeTriple = Graph.TripleType(
            subject: try AnyRDFSubject(alice),
            predicate: RDF.type,
            object: AnyRDFObject(person)
        )
        var graph = Graph()
        try graph.insert(Graph.TripleType(
            subject: try AnyRDFSubject(person),
            predicate: RDFS.subClassOf,
            object: AnyRDFObject(agent)
        ))
        try graph.insert(typeTriple)
        try graph.insert(ReifiedTriple(reifier: try AnyRDFSubject(reifier), triple: typeTriple))

        let closure = graph.rdfsClosure()

        #expect(graph.contains(Graph.TripleType(
            subject: try AnyRDFSubject(reifier),
            predicate: RDF.reifies,
            object: AnyRDFObject(TripleTerm(subject: typeTriple.subject, predicate: typeTriple.predicate, object: typeTriple.object))
        )))
        #expect(closure.contains(Graph.TripleType(
            subject: try AnyRDFSubject(alice),
            predicate: RDF.type,
            object: AnyRDFObject(agent)
        )))
    }
}
