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

    /// A resource is a Swift object, and its identity is the object's (D3).
    @Test func resourceIdentityIsObjectIdentity() {
        let first: any RDFS.Resource = OWLClass()
        let second: any RDFS.Resource = OWLClass()
        #expect(first === first)
        #expect(first !== second)
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
}
