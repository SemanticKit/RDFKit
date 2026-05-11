import Testing
import SemanticKit
@testable import RDFKit

@Test func owlFunctionalSyntaxParsesAdvancedAxioms() async throws {
    let text = """
    Ontology(<http://example.com#> <http://example.com#v1>
        Declaration(Class(<http://example.com#Person>))
        Declaration(Class(<http://example.com#Employee>))
        Declaration(ObjectProperty(<http://example.com#manages>))
        Declaration(DataProperty(<http://example.com#age>))
        Declaration(NamedIndividual(<http://example.com#Alice>))
        Declaration(NamedIndividual(<http://example.com#Bob>))
        SubClassOf(<http://example.com#Employee> <http://example.com#Person>)
        EquivalentClasses(<http://example.com#Employee> <http://example.com#Worker>)
        DisjointClasses(<http://example.com#Person> <http://example.com#Employee>)
        ClassAssertion(<http://example.com#Person> <http://example.com#Alice>)
        ObjectPropertyAssertion(
            <http://example.com#manages>
            <http://example.com#Alice>
            <http://example.com#Bob>
        )
        DataPropertyAssertion(
            <http://example.com#age>
            <http://example.com#Alice>
            "42"^^<http://www.w3.org/2001/XMLSchema#integer>
        )
        AnnotationAssertion(
            <http://www.w3.org/2000/01/rdf-schema#label>
            <http://example.com#Person>
            "Person"@en
        )
    )
    """

    let graph = try Graph(owlFunctionalSyntax: text)
    let person = try IRI("http://example.com#Person")
    let employee = try IRI("http://example.com#Employee")
    let manages = try IRI("http://example.com#manages")
    let alice = try IRI("http://example.com#Alice")
    let bob = try IRI("http://example.com#Bob")
    let label = try IRI("http://www.w3.org/2000/01/rdf-schema#label")

    #expect(graph.contains(Graph.TripleType(
        subject: try AnyRDFSubject(person),
        predicate: OWL.Vocabulary.disjointWith,
        object: AnyRDFObject(employee)
    )))

    #expect(graph.contains(Graph.TripleType(
        subject: try AnyRDFSubject(alice),
        predicate: manages,
        object: AnyRDFObject(bob)
    )))

    #expect(graph.contains(Graph.TripleType(
        subject: try AnyRDFSubject(person),
        predicate: label,
        object: AnyRDFObject(try Literal("Person", languageTag: "en"))
    )))
}
