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
}
