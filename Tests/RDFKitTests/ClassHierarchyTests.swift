import Testing
import RDFKit

/// A Swift class whose instances are OWL classes.
private final class OWLClass: OWL.Class {}

@Suite struct ClassHierarchyTests {
    /// owl:Class rdfs:subClassOf rdfs:Class, and rdfs:Class rdfs:subClassOf
    /// rdfs:Resource, hold as protocol inheritance.
    @Test func owlClassIsAnRDFSClassAndAResource() {
        let member: AnyObject = OWLClass()
        #expect(member is OWL.Class)
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    /// An individual is an instance of a generated class, and its identity is
    /// the object's (D3).
    @Test func individualIdentityIsObjectIdentity() {
        let first = OWLClass()
        let second = OWLClass()
        #expect(first === first)
        #expect(first !== second)
    }

    /// A literal is a Swift value type (D6), and rdfs:Literal rdfs:subClassOf
    /// rdfs:Resource holds for it.
    @Test func literalIsAValueTypeResource() {
        let literal: Any = Text(value: "Alice")
        #expect(literal is RDFS.Literal)
        #expect(literal is RDFS.Resource)
    }

    private struct Text: RDFS.Literal {
        let value: String
    }

    /// rdf:Property rdfs:subClassOf RDFS.Resource.
    @Test func rdfProperty() {
        let member: AnyObject = RDFProperty()
        #expect(member is RDF.Property)
        #expect(member is RDFS.Resource)
    }

    private final class RDFProperty: RDF.Property {}

    /// rdf:List rdfs:subClassOf RDFS.Resource.
    @Test func rdfList() {
        let member: AnyObject = RDFList()
        #expect(member is RDF.List)
        #expect(member is RDFS.Resource)
    }

    private final class RDFList: RDF.List {}

    /// rdf:Statement rdfs:subClassOf RDFS.Resource.
    @Test func rdfStatement() {
        let member: AnyObject = RDFStatement()
        #expect(member is RDF.Statement)
        #expect(member is RDFS.Resource)
    }

    private final class RDFStatement: RDF.Statement {}

    /// rdf:CompoundLiteral rdfs:subClassOf RDFS.Resource.
    @Test func rdfCompoundLiteral() {
        let member: AnyObject = RDFCompoundLiteral()
        #expect(member is RDF.CompoundLiteral)
        #expect(member is RDFS.Resource)
    }

    private final class RDFCompoundLiteral: RDF.CompoundLiteral {}

    /// rdfs:Literal rdfs:subClassOf RDFS.Resource.
    @Test func rdfsLiteral() {
        let member: AnyObject = RDFSLiteral()
        #expect(member is RDFS.Literal)
        #expect(member is RDFS.Resource)
    }

    private final class RDFSLiteral: RDFS.Literal {}

    /// rdfs:Datatype rdfs:subClassOf RDFS.Class.
    @Test func rdfsDatatype() {
        let member: AnyObject = RDFSDatatype()
        #expect(member is RDFS.Datatype)
        #expect(member is RDFS.Class)
        #expect(member is RDFS.Resource)
    }

    private final class RDFSDatatype: RDFS.Datatype {}

    /// rdfs:Container rdfs:subClassOf RDFS.Resource.
    @Test func rdfsContainer() {
        let member: AnyObject = RDFSContainer()
        #expect(member is RDFS.Container)
        #expect(member is RDFS.Resource)
    }

    private final class RDFSContainer: RDFS.Container {}

    /// owl:Thing and rdfs:Resource are one root (D7).
    @Test func owlThing() {
        #expect(ObjectIdentifier((any OWL.Thing).self) == ObjectIdentifier((any RDFS.Resource).self))
    }

    /// owl:Ontology rdfs:subClassOf RDFS.Resource.
    @Test func owlOntology() {
        let member: AnyObject = OWLOntology()
        #expect(member is OWL.Ontology)
        #expect(member is RDFS.Resource)
    }

    private final class OWLOntology: OWL.Ontology {}

    /// owl:Restriction rdfs:subClassOf OWL.Class.
    @Test func owlRestriction() {
        let member: AnyObject = OWLRestriction()
        #expect(member is OWL.Restriction)
        #expect(member is OWL.Class)
        #expect(member is RDFS.Resource)
    }

    private final class OWLRestriction: OWL.Restriction {}

    /// owl:Axiom rdfs:subClassOf RDFS.Resource.
    @Test func owlAxiom() {
        let member: AnyObject = OWLAxiom()
        #expect(member is OWL.Axiom)
        #expect(member is RDFS.Resource)
    }

    private final class OWLAxiom: OWL.Axiom {}

    /// owl:Annotation rdfs:subClassOf RDFS.Resource.
    @Test func owlAnnotation() {
        let member: AnyObject = OWLAnnotation()
        #expect(member is OWL.Annotation)
        #expect(member is RDFS.Resource)
    }

    private final class OWLAnnotation: OWL.Annotation {}

    /// owl:AllDifferent rdfs:subClassOf RDFS.Resource.
    @Test func owlAllDifferent() {
        let member: AnyObject = OWLAllDifferent()
        #expect(member is OWL.AllDifferent)
        #expect(member is RDFS.Resource)
    }

    private final class OWLAllDifferent: OWL.AllDifferent {}

    /// owl:AllDisjointClasses rdfs:subClassOf RDFS.Resource.
    @Test func owlAllDisjointClasses() {
        let member: AnyObject = OWLAllDisjointClasses()
        #expect(member is OWL.AllDisjointClasses)
        #expect(member is RDFS.Resource)
    }

    private final class OWLAllDisjointClasses: OWL.AllDisjointClasses {}
}
